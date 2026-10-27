import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The roles the tests share.
enum AppColor { primary, onPrimary }

const core.UniboxTheme theme = core.UniboxTheme(
  colors: <AppColor, core.BoxColor>{
    AppColor.primary: core.BoxColor(0xFF6750A4),
    AppColor.onPrimary: core.BoxColor(0xFFFFFFFF),
  },
);

/// The decoration a box was painted with.
BoxDecoration decorationOf(WidgetTester tester) =>
    tester.widget<DecoratedBox>(inNode(find.byType(DecoratedBox))).decoration
        as BoxDecoration;

void main() {
  group('a colour role', () {
    testWidgets('is resolved to the value the theme gives it', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          backgroundColor: core.BoxColor.role(AppColor.primary),
          width: 40,
          height: 40,
        ),
        theme: theme,
      );

      expect(decorationOf(tester).color, const Color(0xFF6750A4));
    });

    testWidgets('resolves a text colour too', (tester) async {
      await pumpNode(
        tester,
        const core.TextNode(
          'Unibox',
          color: core.BoxColor.role(AppColor.primary),
        ),
        theme: theme,
      );

      expect(
        tester.widget<Text>(inNode(find.text('Unibox'))).style?.color,
        const Color(0xFF6750A4),
      );
    });

    testWidgets('resolves a colour a state brings, not only the resting one', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.Box(
          width: 40,
          height: 40,
          enabled: false,
          stateStyles: <core.BoxState, core.BoxStyle>{
            core.BoxState.disabled: core.BoxStyle(
              backgroundColor: core.BoxColor.role(AppColor.primary),
            ),
          },
        ),
        theme: theme,
      );

      expect(decorationOf(tester).color, const Color(0xFF6750A4));
    });

    testWidgets('fails loudly when no theme was given', (tester) async {
      // The tree is validated before it is built, so the failure names the role
      // rather than reaching a widget that has no colour to paint.
      await expectLater(
        pumpNode(
          tester,
          const core.Box(
            backgroundColor: core.BoxColor.role(AppColor.primary),
            width: 40,
            height: 40,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (StateError error) => error.message,
            'message',
            contains('AppColor.primary'),
          ),
        ),
      );
    });

    testWidgets('leaves a literal colour alone', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          backgroundColor: core.BoxColor.white,
          width: 40,
          height: 40,
        ),
        theme: theme,
      );

      expect(decorationOf(tester).color, const Color(0xFFFFFFFF));
    });
  });
}
