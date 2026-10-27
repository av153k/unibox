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
}
