import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The press callback reports the local position and the device, which is what an
/// effect that starts at the pointer reads.
void main() {
  group('Box.onTapDown', () {
    testWidgets('reports where the press landed inside the box', (
      WidgetTester tester,
    ) async {
      core.BoxTapEvent? seen;

      await pumpNode(
        tester,
        core.Box(
          width: 200,
          height: 100,
          onTapDown: (core.BoxTapEvent event) => seen = event,
          children: const <core.UINode>[core.TextNode('Tap')],
        ),
      );

      final Offset topLeft = tester.getTopLeft(find.byKey(nodeKey));
      await tester.tapAt(topLeft + const Offset(12, 8));
      await tester.pump();

      expect(seen, isNotNull);
      expect(seen!.position.x, closeTo(12, 0.5));
      expect(seen!.position.y, closeTo(8, 0.5));
      expect(seen!.pointer, core.BoxPointerKind.touch);
    });

    testWidgets('fires before the tap, and leaves onTap alone', (
      WidgetTester tester,
    ) async {
      final List<String> order = <String>[];

      await pumpNode(
        tester,
        core.Box(
          width: 120,
          height: 60,
          onTapDown: (core.BoxTapEvent event) => order.add('down'),
          onTap: () => order.add('tap'),
        ),
      );

      await tester.tap(find.byKey(nodeKey));
      await tester.pump();

      expect(order, <String>['down', 'tap']);
    });
  });
}
