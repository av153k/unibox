import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';

import 'support/harness.dart';

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
      }
    });

    testWidgets('renders the shared number of fields', (tester) async {
      await pumpApp(tester);

      expect(find.byType(TextField), findsNWidgets(CardParity.inputCount));
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
