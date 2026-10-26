import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The [Text] widget rendered by the harness.
Text renderedText(WidgetTester tester) =>
    tester.widget<Text>(inNode(find.byType(Text)));

void main() {
  group('TextNode', () {
    testWidgets('renders the text content', (tester) async {
      await pumpNode(tester, const core.TextNode('Hello Unibox'));

      expect(find.text('Hello Unibox'), findsOneWidget);
    });

    testWidgets('leaves the typography to the ambient default style', (
      tester,
    ) async {
      await pumpNode(tester, const core.TextNode('Plain'));

      expect(renderedText(tester).style, isNull);
      expect(renderedText(tester).textAlign, isNull);
      expect(renderedText(tester).maxLines, isNull);
      expect(renderedText(tester).overflow, isNull);
    });

    testWidgets('applies size, weight and color', (tester) async {
      await pumpNode(
        tester,
        const core.TextNode(
          'Styled',
          fontSize: 18,
          fontWeight: core.FontWeight.semiBold,
          color: core.BoxColor.black,
        ),
      );

      final TextStyle style = renderedText(tester).style!;

      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, const Color(0xFF000000));
    });

    testWidgets('maps every font weight', (tester) async {
      const Map<core.FontWeight, FontWeight> weights =
          <core.FontWeight, FontWeight>{
            core.FontWeight.normal: FontWeight.w400,
            core.FontWeight.medium: FontWeight.w500,
            core.FontWeight.semiBold: FontWeight.w600,
            core.FontWeight.bold: FontWeight.w700,
          };

      for (final MapEntry<core.FontWeight, FontWeight> entry
          in weights.entries) {
        await pumpNode(tester, core.TextNode('Weight', fontWeight: entry.key));

        expect(renderedText(tester).style!.fontWeight, entry.value);
      }
    });

    testWidgets('maps text alignment', (tester) async {
      const Map<core.TextAlign, TextAlign> aligns = <core.TextAlign, TextAlign>{
        core.TextAlign.left: TextAlign.left,
        core.TextAlign.center: TextAlign.center,
        core.TextAlign.right: TextAlign.right,
        core.TextAlign.justify: TextAlign.justify,
      };

      for (final MapEntry<core.TextAlign, TextAlign> entry in aligns.entries) {
        await pumpNode(tester, core.TextNode('Aligned', textAlign: entry.key));

        expect(renderedText(tester).textAlign, entry.value);
      }
    });

    testWidgets('applies maxLines and overflow', (tester) async {
      await pumpNode(
        tester,
        const core.TextNode(
          'Truncated',
          maxLines: 2,
          overflow: core.TextOverflow.ellipsis,
        ),
      );

      expect(renderedText(tester).maxLines, 2);
      expect(renderedText(tester).overflow, TextOverflow.ellipsis);
    });

    testWidgets('maps clip overflow', (tester) async {
      await pumpNode(
        tester,
        const core.TextNode('Clipped', overflow: core.TextOverflow.clip),
      );

      expect(renderedText(tester).overflow, TextOverflow.clip);
    });

    testWidgets('wraps inside a constrained box', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          width: 80,
          children: [core.TextNode('A fairly long sentence that wraps')],
        ),
      );

      final Text text = renderedText(tester);

      expect(text.maxLines, isNull);
      expect(tester.getSize(find.byType(Text)).width, lessThanOrEqualTo(80));
      expect(tester.getSize(find.byType(Text)).height, greaterThan(20));
    });

    testWidgets('sits between the children of a box', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          direction: core.Axis.vertical,
          gap: 8,
          children: [core.TextNode('First'), core.TextNode('Second')],
        ),
      );

      final Column column = tester.widget<Column>(find.byType(Column));

      expect(column.children, hasLength(3));
      expect((column.children[1] as SizedBox).height, 8);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });
  });
}
