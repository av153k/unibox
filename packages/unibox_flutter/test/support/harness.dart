import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

/// Key wrapping the rendered root node so tests can measure it.
const Key nodeKey = ValueKey<String>('unibox-node');

/// Renders [node] centered on the default 800x600 test surface.
///
/// The [Center] hands loose constraints to the node, which mirrors how a node
/// is usually embedded and keeps fixed sizes measurable.
Future<void> pumpNode(WidgetTester tester, core.UINode node) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: KeyedSubtree(key: nodeKey, child: renderFlutter(node)),
      ),
    ),
  );
}

/// Restricts [matching] to the subtree of the rendered root node.
Finder inNode(Finder matching) =>
    find.descendant(of: find.byKey(nodeKey), matching: matching);

/// The decoration painted by the rendered root node, if any.
BoxDecoration? decorationOf(WidgetTester tester) {
  final Finder finder = inNode(find.byType(DecoratedBox));
  if (finder.evaluate().isEmpty) {
    return null;
  }
  return tester.widget<DecoratedBox>(finder.first).decoration as BoxDecoration;
}
