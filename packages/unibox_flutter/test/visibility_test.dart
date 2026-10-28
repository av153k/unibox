import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// Pumps [node] into a box of exactly [width] logical pixels.
///
/// The renderer measures the box it draws a node in, not the window, so the width
/// has to come from the widget tree — which is also what the container query on the
/// web measures.
Future<void> pumpAtWidth(
  WidgetTester tester,
  core.UINode node,
  double width,
) async {
  // Room for a 950 pixel box: the surface is 800 wide by default, and a `SizedBox`
  // wider than the surface is clamped to it.
  await tester.binding.setSurfaceSize(const Size(1000, 700));

  await pumpNode(
    tester,
    node,
    wrap: (Widget child) => Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, height: 600, child: child),
    ),
  );
}

void main() {
  const core.Box tree = core.Box(
    width: double.infinity,
    children: <core.UINode>[
      core.Box(visibleFrom: 900, children: <core.UINode>[core.TextNode('map')]),
      core.Box(
        visibleUntil: 900,
        children: <core.UINode>[core.TextNode('floating button')],
      ),
    ],
  );

  group('a width threshold', () {
    testWidgets('draws the wide-only box only when the box is wide', (
      tester,
    ) async {
      await pumpAtWidth(tester, tree, 850);
      expect(find.text('map'), findsNothing);

      await pumpAtWidth(tester, tree, 950);
      expect(find.text('map'), findsOneWidget);
    });

    testWidgets('draws the narrow-only box only when the box is narrow', (
      tester,
    ) async {
      await pumpAtWidth(tester, tree, 850);
      expect(find.text('floating button'), findsOneWidget);

      await pumpAtWidth(tester, tree, 950);
      expect(find.text('floating button'), findsNothing);
    });

    testWidgets('reads the threshold as the next width, not this one', (
      tester,
    ) async {
      await pumpAtWidth(tester, tree, 899);
      expect(find.text('map'), findsNothing);
      expect(find.text('floating button'), findsOneWidget);

      // The range is half open: 900 belongs to the wide side.
      await pumpAtWidth(tester, tree, 900);
      expect(find.text('map'), findsOneWidget);
      expect(find.text('floating button'), findsNothing);
    });

    testWidgets('keeps the hidden subtree alive', (tester) async {
      await pumpAtWidth(tester, tree, 850);

      // Not painted, but still built: `maintainState` is what makes a box a wider
      // box draws again come back with the state it had, like `display: none`.
      final Iterable<Visibility> visibilities = tester.widgetList<Visibility>(
        find.byType(Visibility),
      );

      expect(visibilities.any((Visibility v) => !v.visible), isTrue);
      expect(
        visibilities
            .where((Visibility v) => !v.visible)
            .every((Visibility v) => v.maintainState),
        isTrue,
      );
    });
  });
}
