import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

import 'support/harness.dart';

/// A widget that only exists to prove an embed is rendered as itself.
class _Marker extends StatelessWidget {
  const _Marker(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(label);
}

/// An embed of another target, which no Flutter renderer can draw.
final class _ForeignEmbed extends core.EmbedNode {
  const _ForeignEmbed();

  @override
  Object get payload => 42;
}

void main() {
  group('WidgetNode', () {
    testWidgets('renders the widget inside the surrounding box', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.Box(
          direction: core.Axis.vertical,
          gap: 8,
          children: <core.UINode>[
            core.TextNode('before'),
            WidgetNode(_Marker('chart')),
          ],
        ),
      );

      expect(find.text('before'), findsOneWidget);
      expect(find.byType(_Marker), findsOneWidget);
      expect(find.text('chart'), findsOneWidget);
    });

    testWidgets('carries the key of its node', (tester) async {
      await pumpNode(tester, const WidgetNode(_Marker('chart'), key: 'chart'));

      expect(find.byKey(const ValueKey<Object>('chart')), findsOneWidget);
    });

    testWidgets('exposes the widget as its payload', (tester) async {
      const WidgetNode node = WidgetNode(_Marker('chart'));

      expect(node.payload, isA<_Marker>());
      expect(node.children, isEmpty);
    });

    testWidgets('reports an embed of another target', (tester) async {
      expect(
        () => renderFlutter(const _ForeignEmbed()),
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
