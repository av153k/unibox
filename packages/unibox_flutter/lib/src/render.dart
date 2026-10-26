import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'box.dart';
import 'image_node.dart';
import 'keys.dart';
import 'link_node.dart';
import 'stack_node.dart';
import 'text_input_node.dart';
import 'text_node.dart';

/// Renders [node] as a Flutter [Widget].
///
/// ```dart
/// runApp(UniboxApp(child: renderFlutter(myNode)));
/// ```
///
/// Throws an [UnsupportedError] when [node] has no Flutter renderer yet.
///
/// A [core.PositionedNode] only carries offsets for an enclosing
/// [core.StackNode], so rendering one on its own renders its child.
///
/// Every widget is created with the key of its node, so reordering a list of
/// nodes preserves the state of each child instead of moving it to the node
/// that took over the position.
Widget renderFlutter(core.UINode node) {
  return switch (node) {
    final core.Box box => UniboxBox(box: box, key: toFlutterKey(box.key)),
    final core.TextNode text => UniboxText(
      node: text,
      key: toFlutterKey(text.key),
    ),
    final core.ImageNode image => UniboxImage(
      node: image,
      key: toFlutterKey(image.key),
    ),
    final core.LinkNode link => UniboxLink(
      node: link,
      key: toFlutterKey(link.key),
    ),
    final core.StackNode stack => UniboxStack(
      node: stack,
      key: toFlutterKey(stack.key),
    ),
    final core.PositionedNode positioned => KeyedSubtree(
      key: toFlutterKey(positioned.key),
      child: renderFlutter(positioned.child),
    ),
    final core.TextInputNode input => UniboxTextInput(
      node: input,
      key: toFlutterKey(input.key),
    ),
    _ => throw UnsupportedError('No Flutter renderer for ${node.runtimeType}.'),
  };
}

/// Flutter rendering helpers for Unibox nodes.
extension UINodeFlutterRenderer on core.UINode {
  /// Renders this node as a Flutter [Widget].
  ///
  /// Shorthand for `renderFlutter(this)`.
  Widget toWidget() => renderFlutter(this);
}
