import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_jaspr/unibox_jaspr.dart';

void main() {
  group('renderJaspr validation', () {
    test('accepts a well formed tree', () {
      expect(
        () => renderJaspr(
          const core.Box(children: <core.UINode>[core.TextNode('Hello')]),
        ),
        returnsNormally,
      );
    });

    test('throws for a link nested in a link', () {
      final core.LinkNode node = core.LinkNode(
        'https://a.dev',
        child: core.LinkNode(
          'https://b.dev',
          child: const core.TextNode('inner'),
        ),
      );

      expect(() => renderJaspr(node), throwsStateError);
    });

    test('renders a positioned node outside a stack anyway', () {
      expect(
        () => renderJaspr(
          const core.Box(
            children: <core.UINode>[
              core.PositionedNode(top: 4, child: core.TextNode('badge')),
            ],
          ),
        ),
        returnsNormally,
      );
    });
  });
}
