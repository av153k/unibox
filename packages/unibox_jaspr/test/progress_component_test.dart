import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

void main() {
  group('ProgressNode', () {
    testComponents('writes a labelled progressbar of the stated size', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.ProgressNode(
          value: 0.5,
          size: 32,
          strokeWidth: 3,
          semanticsLabel: 'Uploading',
        ),
      );

      final element = elementOf(find.tag('div'));
      expect(element.attributes?['role'], 'progressbar');
      expect(element.attributes?['aria-valuenow'], '0.5');
      expect(element.attributes?['aria-label'], 'Uploading');
      expect(stylesOf(find.tag('div'))['width'], '32.0px');
      expect(stylesOf(find.tag('div'))['background'], contains('50.00%'));
      expect(stylesOf(find.tag('div')).containsKey('animation'), isFalse);
    });

    testComponents('turns an indeterminate ring with a keyframes rule', (
      tester,
    ) async {
      pumpNode(tester, const core.ProgressNode());

      final element = elementOf(find.tag('div'));
      expect(element.attributes?.containsKey('aria-valuenow'), isFalse);
      expect(stylesOf(find.tag('div'))['animation'], contains('infinite'));
    });
  });
}
