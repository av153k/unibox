import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_testing/unibox_testing.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/appearance.dart';
import 'support/harness.dart';

/// Checks this renderer against the presentation contract of the workspace.
///
/// Every case in [boxCases] is rendered and the appearance is read back out of
/// the CSS the renderer emitted, so a box that loses a token fails here instead
/// of only looking different from the page the Flutter renderer draws. The
/// Flutter suite walks the same table, which is what makes the two answers
/// comparable.
///
/// The same is done for [textCases]: the declarations this renderer emitted for
/// the text are compared with the typography the table asks for, so a text token
/// that stops reaching the page fails here rather than in a screenshot. Both
/// tables are walked by both suites, which is as close to "the two renderings look
/// the same" as a test without a browser can come.
void main() {
  group('box conformance', () {
    for (final BoxCase boxCase in boxCases) {
      testComponents(boxCase.description, (ComponentTester tester) async {
        pumpNode(tester, boxCase.box);

        expect(
          appearanceOf().differencesFrom(boxCase.expected),
          isEmpty,
          reason:
              'The web renderer renders "${boxCase.description}" differently.',
        );
      });
    }
  });

  group('text conformance', () {
    for (final TextCase textCase in textCases) {
      testComponents(textCase.description, (ComponentTester tester) async {
        pumpNode(tester, textCase.node);

        expect(
          textAppearanceOf().differencesFrom(textCase.expected),
          isEmpty,
          reason:
              'The web renderer typesets "${textCase.description}" differently.',
        );
        expect(
          renderedTextOf(),
          textCase.node.text,
          reason:
              'The web renderer renders "${textCase.description}" without its '
              'text.',
        );
      });
    }
  });

  group('model default', () {
    testComponents(
      'typesets an undeclared text with the typography of the model',
      (ComponentTester tester) async {
        pumpNode(tester, const core.TextNode('Hello'));

        // Not the browser's own default: the renderer puts the typography of the
        // model in a `:root` rule, which is what the Flutter renderer installs
        // around the tree.
        expect(
          resolvedTextAppearanceOf().differencesFrom(defaultTextAppearance),
          isEmpty,
          reason: 'The web renderer typesets an undeclared text differently.',
        );
      },
    );

    testComponents('lets a declared token win over the default', (
      ComponentTester tester,
    ) async {
      pumpNode(
        tester,
        const core.TextNode(
          'Hello',
          fontSize: 24,
          color: core.BoxColor.white,
          fontFamily: 'Inter',
        ),
      );

      expect(
        resolvedTextAppearanceOf().differencesFrom(
          defaultTextAppearance.copyWith(
            fontSize: 24,
            color: core.BoxColor.white,
            fontFamily: 'Inter',
          ),
        ),
        isEmpty,
        reason: 'The web renderer lets a declared token lose to the default.',
      );
    });
  });
}
