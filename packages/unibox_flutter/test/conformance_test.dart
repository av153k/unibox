import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_conformance/unibox_conformance.dart';

import 'support/appearance.dart';
import 'support/harness.dart';

/// Checks this renderer against the presentation contract of the workspace.
///
/// Every case in [boxCases] is rendered and the appearance is read back out of
/// the widget tree this renderer built, so a box that loses a token fails here
/// instead of only looking different from the page the web renderer draws. The
/// Jaspr suite walks the same table, which is what makes the two answers
/// comparable.
void main() {
  group('box conformance', () {
    for (final BoxCase boxCase in boxCases) {
      testWidgets(boxCase.description, (WidgetTester tester) async {
        await pumpNode(tester, boxCase.box);

        expect(
          appearanceOf(tester).differencesFrom(boxCase.expected),
          isEmpty,
          reason: 'Flutter renders "${boxCase.description}" differently.',
        );
      });
    }
  });
}
