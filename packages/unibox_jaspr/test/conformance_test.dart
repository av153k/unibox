import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_conformance/unibox_conformance.dart';

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
}
