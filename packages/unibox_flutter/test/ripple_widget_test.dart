import 'package:flutter/material.dart' show InkResponse;
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// A ripple is motion, so it is not in the appearance contract; what a renderer can
/// be held to is that it does the motion the node asks for, and does nothing when
/// the node asks for none.
void main() {
  group('Box ripple', () {
    testWidgets('splashes over a box that asks for one', (
      WidgetTester tester,
    ) async {
      int taps = 0;

      await pumpNode(
        tester,
        core.Box(
          ripple: const core.BoxRipple(),
          onTap: () => taps++,
          children: const <core.UINode>[core.TextNode('Tap')],
        ),
      );

      expect(inNode(find.byType(InkResponse)), findsOneWidget);

      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();

      // One recogniser, so one call: the ink response takes the tap and the
      // gesture detector steps aside.
      expect(taps, 1);
    });

    testWidgets('adds no material to a box without one', (
      WidgetTester tester,
    ) async {
      await pumpNode(tester, const core.Box());

      expect(inNode(find.byType(InkResponse)), findsNothing);
    });
  });
}
