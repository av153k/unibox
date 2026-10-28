import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// A stack is a layer, so a box can wrap one and clip it. The web renderer draws
/// that shape already; the Flutter one used to refuse it, because a flex hands its
/// children an unbounded main axis and a stack cannot be laid out in one.
void main() {
  testWidgets('lays a stack out inside a box that clips it', (
    WidgetTester tester,
  ) async {
    await pumpNode(
      tester,
      core.Box(
        width: 200,
        height: 100,
        overflow: core.Overflow.hidden,
        borderRadius: 12,
        children: <core.UINode>[
          core.StackNode(
            children: <core.UINode>[
              core.PositionedNode(
                left: 10,
                top: 20,
                child: const core.Box(width: 30, height: 30),
              ),
            ],
          ),
        ],
      ),
    );

    // The layer takes the box's own size, which is what makes the clip mean
    // something: 200x100, with the child where it was placed.
    expect(tester.getSize(find.byType(Stack)), const Size(200, 100));
    expect(
      tester.getTopLeft(find.byType(Stack)),
      tester.getTopLeft(find.byKey(nodeKey)),
    );
    expect(
      tester.getTopLeft(find.byType(ClipRRect)),
      tester.getTopLeft(find.byKey(nodeKey)),
    );
    expect(tester.getSize(find.byType(ClipRRect)), const Size(200, 100));
  });
}
