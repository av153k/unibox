import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

void main() {
  group('GridNode', () {
    testComponents('writes the reflow as one auto-fill declaration', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.GridNode(
          minItemWidth: 280,
          maxColumns: 3,
          gap: 16,
          children: <core.UINode>[core.Box(height: 40)],
        ),
      );

      final Map<String, String> styles = stylesOf(find.tag('div').first);

      expect(styles['display'], 'grid');
      expect(styles['gap'], '16px');
      expect(styles['align-items'], 'start');
      expect(
        styles['grid-template-columns'],
        'repeat(auto-fill, minmax(min(100%, max(280px, (100% - 32px) / 3)), 1fr))',
      );
    });

    testComponents('omits the cap and the gutter when there are none', (
      tester,
    ) async {
      pumpNode(tester, const core.GridNode(minItemWidth: 240));

      final Map<String, String> styles = stylesOf(find.tag('div').first);

      expect(
        styles['grid-template-columns'],
        'repeat(auto-fill, minmax(min(100%, 240px), 1fr))',
      );
      expect(styles.containsKey('gap'), isFalse);
    });

    testComponents('reads a fractional minimum as CSS does', (tester) async {
      pumpNode(
        tester,
        const core.GridNode(minItemWidth: 262.5, maxColumns: 2, gap: 12.5),
      );

      expect(
        stylesOf(find.tag('div').first)['grid-template-columns'],
        'repeat(auto-fill, minmax(min(100%, max(262.5px, (100% - 12.5px) / 2)), 1fr))',
      );
    });

    testComponents('renders the cards in reading order', (tester) async {
      pumpNode(
        tester,
        const core.GridNode(
          minItemWidth: 280,
          gap: 16,
          children: <core.UINode>[
            core.TextNode('one'),
            core.TextNode('two'),
            core.TextNode('three'),
          ],
        ),
      );

      final List<String> texts = <String>[
        for (final TestRenderElement span in elementsOf(find.tag('span')))
          span.children
              .whereType<TestRenderText>()
              .map((TestRenderText t) => t.text)
              .join(),
      ];

      expect(texts, <String>['one', 'two', 'three']);
    });
  });
}
