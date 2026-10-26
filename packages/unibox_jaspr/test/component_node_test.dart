import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_jaspr/unibox_jaspr.dart';

import 'support/harness.dart';

/// A component that only exists to prove an embed is rendered as itself.
class _Marker extends StatelessComponent {
  const _Marker(this.label);

  final String label;

  @override
  Component build(BuildContext context) =>
      span(<Component>[Component.text(label)]);
}

/// An embed of another target, which no web renderer can draw.
final class _ForeignEmbed extends core.EmbedNode {
  const _ForeignEmbed();

  @override
  Object get payload => 42;
}

void main() {
  group('ComponentNode', () {
    testComponents('renders the component inside the surrounding box', (
      tester,
    ) async {
      pumpNode(
        tester,
        core.Box(
          direction: core.Axis.vertical,
          gap: 16,
          children: <core.UINode>[
            const core.TextNode('before'),
            const ComponentNode(_Marker('chart')),
          ],
        ),
      );

      expect(find.text('before'), findsOneComponent);
      expect(find.byType(_Marker), findsOneComponent);
      expect(find.text('chart'), findsOneComponent);
    });

    testComponents('carries the key of its node', (tester) async {
      pumpNode(tester, const ComponentNode(_Marker('chart'), key: 'chart'));

      expect(find.byKey(const ValueKey<Object>('chart')), findsOneComponent);
    });

    test('exposes the component as its payload', () {
      const ComponentNode node = ComponentNode(_Marker('chart'));

      expect(node.payload, isA<_Marker>());
      expect(node.children, isEmpty);
    });

    test('reports an embed of another target', () {
      expect(
        () => renderJaspr(const _ForeignEmbed()),
        throwsA(
          isA<UnsupportedError>().having(
            (UnsupportedError error) => error.message,
            'message',
            contains('int'),
          ),
        ),
      );
    });
  });
}
