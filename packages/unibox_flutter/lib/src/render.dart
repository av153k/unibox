import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'box.dart';
import 'embed_node.dart';
import 'image_node.dart';
import 'keys.dart';
import 'link_node.dart';
import 'stack_node.dart';
import 'text_input_node.dart';
import 'text_node.dart';
import 'text_style_scope.dart';
import 'values.dart';

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
/// The tree is wrapped in the typography of the model
/// ([core.BoxTextStyle.defaults]), so a text that declares nothing is typeset the
/// way the web renderer typesets it instead of the way this host happens to
/// default. The wrapper only lays its style over the ambient one: a host that
/// provides a font family — through a `MaterialApp` theme, say — keeps it, and a
/// box in the tree can declare any token to override it.
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

  return _withDefaultTypography(renderNode(node));
}

/// Wraps [child] in the typography of the model, `BoxTextStyle.defaults`.
///
/// The web renderer answers the same question with a `:root` rule, so a text
/// that declares nothing looks the same on both targets instead of inheriting
/// each host's own default. `DefaultTextStyle.merge` only lays the tokens of the
/// default over the ambient style, so a host that brought a font family — through
/// a `MaterialApp` theme, say — keeps it: the model owns what a text looks like,
/// the application owns which font it is.
///
/// A `TextField` ignores the default text style and reads
/// [UniboxTextStyleScope] instead, so the default is installed in both: without
/// it a field would fall back to the Material input style while the `<input>` of
/// the web renderer inherits the tree's typography.
Widget _withDefaultTypography(Widget child) {
  return DefaultTextStyle.merge(
    style: toTextStyle(core.BoxTextStyle.defaults),
    child: UniboxTextStyleScope(
      style: core.BoxTextStyle.defaults,
      child: child,
    ),
  );
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
    final WidgetNode embed => KeyedSubtree(
      key: toFlutterKey(embed.key),
      child: embed.widget,
    ),
    final core.EmbedNode embed => throw UnsupportedError(
      'No Flutter renderer for ${embed.runtimeType}: it carries a '
      '${embed.payload.runtimeType}, and only a WidgetNode can be rendered by '
      'this package.',
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
