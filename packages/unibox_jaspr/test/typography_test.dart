import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The styles of the root `div` of a rendered box.
Map<String, String> boxStyles(ComponentTester tester, core.UINode node) {
  pumpNode(tester, node);
  return stylesOf(find.tag('div').first);
}

void main() {
  group('inherited typography', () {
    testComponents('emits the box typography as inherited CSS', (tester) async {
      final Map<String, String> styles = boxStyles(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(
            fontSize: 22,
            fontWeight: core.FontWeight.bold,
            color: core.BoxColor.black,
            lineHeight: 1.5,
            letterSpacing: 2,
            fontFamily: 'Inter',
          ),
          children: <core.UINode>[core.TextNode('Hello')],
        ),
      );

      expect(styles['font-size'], '22px');
      expect(styles['font-weight'], '700');
      expect(styles['color'], '#000000');
      expect(styles['line-height'], '1.5');
      expect(styles['letter-spacing'], '2px');
      expect(styles['font-family'], "'Inter'");
    });

    testComponents('emits no font declaration without typography', (
      tester,
    ) async {
      final Map<String, String> styles = boxStyles(
        tester,
        const core.Box(children: <core.UINode>[core.TextNode('Hello')]),
      );

      expect(styles.containsKey('font-size'), isFalse);
      expect(styles.containsKey('font-family'), isFalse);
    });

    testComponents('takes the typography from a style token', (tester) async {
      final Map<String, String> styles = boxStyles(
        tester,
        const core.Box(
          styles: <core.BoxStyle>[
            core.BoxStyle(textStyle: core.BoxTextStyle(fontSize: 18)),
          ],
        ),
      );

      expect(styles['font-size'], '18px');
    });

    testComponents('leaves the typography to the enclosing box', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(fontSize: 22),
          children: <core.UINode>[core.TextNode('Hello')],
        ),
      );

      final Map<String, String> span = stylesOf(find.tag('span').first);

      expect(span.containsKey('font-size'), isFalse);
    });

    testComponents('emits only the tokens a text node overrides', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          textStyle: core.BoxTextStyle(fontSize: 22),
          children: <core.UINode>[
            core.TextNode(
              'Hello',
              fontSize: 12,
              lineHeight: 1.4,
              fontFamily: 'Inter',
              letterSpacing: 0.5,
            ),
          ],
        ),
      );

      final Map<String, String> span = stylesOf(find.tag('span').first);

      expect(span['font-size'], '12px');
      expect(span['line-height'], '1.4');
      expect(span['font-family'], "'Inter'");
      expect(span['letter-spacing'], '0.5px');
    });

    testComponents('lets a text field inherit the ambient font', (
      tester,
    ) async {
      pumpNode(tester, const core.TextInputNode(placeholder: 'Email'));

      expect(stylesOf(find.tag('input').first)['font'], 'inherit');
    });
  });
}
