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
/// In debug builds the tree is validated first: a tree that a renderer cannot
/// honour reports the offending nodes through [debugPrint], and an invalid one
/// throws a [StateError].
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
  _reportTreeIssues(node);
  return renderNode(node);
}

/// Renders [node] without validating its subtree.
///
/// The renderers use it for children, which were validated as part of the tree
/// their caller rendered. Prefer [renderFlutter].
Widget renderNode(core.UINode node) {
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
      child: renderNode(positioned.child),
    ),
    final core.TextInputNode input => UniboxTextInput(
      node: input,
      key: toFlutterKey(input.key),
    ),
    _ => throw UnsupportedError('No Flutter renderer for ${node.runtimeType}.'),
  };
}

/// Reports the tree issues of [node], in debug builds only.
///
/// Warnings are printed, errors throw: a tree that no target can render has to
/// fail loudly while it is being built, not silently in production.
void _reportTreeIssues(core.UINode node) {
  assert(() {
    final List<core.TreeIssue> issues = core.validateTree(node);
    final List<core.TreeIssue> errors = issues
        .where((core.TreeIssue issue) => issue.isError)
        .toList(growable: false);

    if (errors.isNotEmpty) {
      throw StateError(
        'Unibox: the node tree cannot be rendered:\n${errors.join('\n')}',
      );
    }

    for (final core.TreeIssue issue in issues) {
      debugPrint('Unibox warning: $issue');
    }

    return true;
  }());
}

/// Flutter rendering helpers for Unibox nodes.
extension UINodeFlutterRenderer on core.UINode {
  /// Renders this node as a Flutter [Widget].
  ///
  /// Shorthand for `renderFlutter(this)`.
  Widget toWidget() => renderFlutter(this);
}
