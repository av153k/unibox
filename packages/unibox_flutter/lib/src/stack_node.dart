import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'keys.dart';
import 'render.dart';

/// Renders a [core.StackNode] as a Flutter [Stack].
///
/// Children are painted in order, so the last child ends up on top. Children
/// that are not [core.PositionedNode]s keep their natural size in the top start
/// corner. Like CSS `overflow: visible`, the stack does not clip its content.
class UniboxStack extends StatelessWidget {
  /// Creates a renderer for [node].
  const UniboxStack({required this.node, super.key});

  /// The node being rendered.
  final core.StackNode node;

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        for (final core.UINode child in node.children) _child(child),
      ],
    );

    if (node.width != null || node.height != null) {
      content = SizedBox(
        width: node.width,
        height: node.height,
        child: content,
      );
    }

    return content;
  }

  /// Renders [node] as a stack child, honouring its absolute offsets.
  Widget _child(core.UINode node) {
    if (node is! core.PositionedNode) {
      return renderFlutter(node);
    }

    final Widget child = renderFlutter(node.child);

    if (node.isUnpositioned) {
      return child;
    }

    return Positioned(
      key: toFlutterKey(node.key),
      top: node.top,
      right: node.right,
      bottom: node.bottom,
      left: node.left,
      child: child,
    );
  }
}
