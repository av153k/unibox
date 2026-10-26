import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

import 'support/harness.dart';
import 'support/visual_facts.dart';

/// The style a rendered text ends up with, inheritance included.
TextStyle styleOf(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

/// The Flutter weight of a core weight.
FontWeight weightOf(core.FontWeight weight) {
  return switch (weight) {
    core.FontWeight.normal => FontWeight.w400,
    core.FontWeight.medium => FontWeight.w500,
    core.FontWeight.semiBold => FontWeight.w600,
    core.FontWeight.bold => FontWeight.w700,
  };
}

/// The Flutter colour of a core colour.
Color colorOf(core.BoxColor color) => Color(color.value);

void main() {
  group('card parity', () {
    testWidgets('renders every box the way the fixture describes it', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(boxFactsOf(tester), CardParity.boxes);
    });

    testWidgets('renders every text with the shared typography', (
      tester,
    ) async {
      await pumpApp(tester);

      for (final TextFact fact in CardParity.texts) {
        final TextStyle style = styleOf(tester, fact.text);
        final core.BoxTextStyle expected = fact.typography;
        final core.FontWeight? weight = expected.fontWeight;
        final core.BoxColor? color = expected.color;

        expect(find.text(fact.text), findsOneWidget, reason: fact.text);
        if (expected.fontSize != null) {
          expect(style.fontSize, expected.fontSize, reason: fact.text);
        }
        if (weight != null) {
          expect(style.fontWeight, weightOf(weight), reason: fact.text);
        }
        if (color != null) {
          expect(style.color, colorOf(color), reason: fact.text);
        }
        if (expected.lineHeight != null) {
          expect(style.height, expected.lineHeight, reason: fact.text);
        }
      }
    });

    testWidgets('renders the shared number of fields', (tester) async {
      await pumpApp(tester);

      expect(find.byType(TextField), findsNWidgets(CardParity.inputCount));
    });

    testWidgets('renders a field without Material chrome', (tester) async {
      // The box around a field draws the border and the padding, so the field
      // itself must not add any: a `TextField` with a Material decoration would
      // draw an underline, a 48 pixel minimum height and its own content padding
      // that the plain `<input>` of the web renderer does not have.
      await pumpApp(tester);

      final TextField field = tester.widget<TextField>(nameField());
      final InputDecoration decoration = field.decoration!;

      expect(decoration, InputDecoration.collapsed(hintText: 'Ada Lovelace'));
      expect(decoration.isCollapsed, isTrue);
      expect(decoration.contentPadding, EdgeInsets.zero);
      // Without a decoration the field is exactly one line tall, which is what
      // the browser gives a field whose padding and border are stripped.
      final double lineHeight =
          ExampleType.body.fontSize! * ExampleType.body.lineHeight!;
      expect(
        tester.getSize(nameField()).height,
        closeTo(lineHeight, 1),
        reason: 'a Material field would be 48 pixels tall',
      );
      // The field adopts the typography of the card, the line height included,
      // which is what sizes it.
      expect(field.style?.fontSize, ExampleType.body.fontSize);
      expect(field.style?.height, ExampleType.body.lineHeight);
    });

    testWidgets('fills the surface the host gives it', (tester) async {
      // The web page box fills the viewport, so the Flutter box has to fill the
      // window instead of shrinking to the card: same tree, same surface.
      await pumpApp(tester);

      final Rect page = tester.getRect(find.byType(UniboxBox).first);

      expect(
        page,
        Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio,
      );
    });

    testWidgets('describes every shared role', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpApp(tester);

      for (final RoleFact fact in CardParity.roles) {
        final SemanticsNode node = tester.getSemantics(find.text(fact.label));

        expect(
          node,
          isSemantics(
            label: fact.label,
            isButton: fact.role == core.BoxRole.button,
            hasCheckedState: fact.role == core.BoxRole.checkbox,
          ),
          reason: fact.label,
        );
      }

      handle.dispose();
    });
  });
}
