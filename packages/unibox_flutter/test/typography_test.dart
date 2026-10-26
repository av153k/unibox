import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The style the rendered paragraph of [text] resolves to.
///
/// Reading it from the render object is the only honest check: it holds the
/// merged result of the node, the enclosing boxes and the ambient style.
TextStyle styleOf(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

void main() {
  group('inherited typography', () {
    testWidgets('passes the box typography to a text node', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(
            fontSize: 22,
            fontWeight: core.FontWeight.bold,
            color: core.BoxColor.black,
          ),
          children: <core.UINode>[core.TextNode('Hello')],
        ),
      );

      final TextStyle style = styleOf(tester, 'Hello');

      expect(style.fontSize, 22);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, const Color(0xFF000000));
    });

    testWidgets('lets a node override a single token', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(
            fontSize: 22,
            color: core.BoxColor.black,
            letterSpacing: 2,
          ),
          children: <core.UINode>[core.TextNode('Hello', fontSize: 12)],
        ),
      );

      final TextStyle style = styleOf(tester, 'Hello');

      expect(style.fontSize, 12);
      expect(style.color, const Color(0xFF000000));
      expect(style.letterSpacing, 2);
    });

    testWidgets('lets the closest box win over an outer one', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(
            fontSize: 22,
            color: core.BoxColor.black,
          ),
          children: <core.UINode>[
            core.TextNode('outer'),
            core.Box(
              textStyle: core.BoxTextStyle(color: core.BoxColor.white),
              children: <core.UINode>[core.TextNode('inner')],
            ),
          ],
        ),
      );

      final TextStyle inner = styleOf(tester, 'inner');

      expect(inner.fontSize, 22);
      expect(inner.color, const Color(0xFFFFFFFF));
      expect(styleOf(tester, 'outer').color, const Color(0xFF000000));
    });

    testWidgets('maps the line height and the family', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(lineHeight: 1.5, fontFamily: 'Inter'),
          children: <core.UINode>[core.TextNode('Hello')],
        ),
      );

      final TextStyle style = styleOf(tester, 'Hello');

      expect(style.height, 1.5);
      expect(style.fontFamily, 'Inter');
    });

    testWidgets('takes the typography from a style token', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          style: core.BoxStyle(textStyle: core.BoxTextStyle(fontSize: 18)),
          children: <core.UINode>[core.TextNode('Hello')],
        ),
      );

      expect(styleOf(tester, 'Hello').fontSize, 18);
    });

    testWidgets('leaves the ambient style alone without a typography box', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.Box(children: <core.UINode>[core.TextNode('Hello')]),
      );

      expect(styleOf(tester, 'Hello').fontSize, isNull);
    });

    testWidgets('lets a text field adopt the inherited typography', (
      tester,
    ) async {
      await pumpMaterialNode(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(fontSize: 20),
          children: <core.UINode>[core.TextInputNode(placeholder: 'Email')],
        ),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).style?.fontSize,
        20,
      );
    });

    testWidgets('keeps the material input style without a typography box', (
      tester,
    ) async {
      await pumpMaterialNode(tester, const core.TextInputNode());

      expect(tester.widget<TextField>(find.byType(TextField)).style, isNull);
    });
  });
}
