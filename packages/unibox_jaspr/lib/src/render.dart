import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'box.dart';
import 'default_typography.dart';
import 'embed_node.dart';
import 'image_node.dart';
import 'keys.dart';
import 'link_node.dart';
import 'stack_node.dart';
import 'text_input_node.dart';
import 'text_node.dart';

/// Renders [node] as a Jaspr [Component].
///
/// In debug builds the tree is validated first: a tree that a renderer cannot
/// honour is printed to stdout, and an invalid one throws a [StateError].
///
/// The tree is preceded by the typography of the model
/// ([core.BoxTextStyle.defaults]) as a `:root` rule, so a text that declares
/// nothing is typeset the way the Flutter renderer typesets it instead of the way
/// a browser happens to default. The rule states only what the model declares: a
/// host that sets a `font-family` keeps it, and a box in the tree can declare any
/// token to override the default for its subtree.
///
/// Node types without a web renderer yet throw an [UnsupportedError] so a
/// partially rendered tree can never be shipped silently.
///
/// Every component is created with the key of its node, so reordering a list of
/// nodes keeps each element (and the DOM state it owns) attached to the node it
/// belongs to.
Component renderJaspr(core.UINode node) {
  _reportTreeIssues(node);

  return Component.fragment(<Component>[
    const DefaultTypography(),
    renderNode(node),
  ]);
}

/// Renders [node] without validating its subtree.
///
/// The renderers use it for children, which were validated as part of the tree
/// their caller rendered. Prefer [renderJaspr].
Component renderNode(core.UINode node) {
  return switch (node) {
    final core.Box box => UniboxBox(box: box, key: toJasprKey(box.key)),
    final core.ImageNode image => UniboxImage(
      node: image,
      key: toJasprKey(image.key),
    ),
    final core.LinkNode link => UniboxLink(
      node: link,
      key: toJasprKey(link.key),
    ),
    final core.StackNode stack => UniboxStack(
      node: stack,
      key: toJasprKey(stack.key),
    ),
    final core.PositionedNode positioned => Component.fragment(<Component>[
      renderNode(positioned.child),
    ], key: toJasprKey(positioned.key)),
    final core.TextInputNode textInput => UniboxTextInput(
      node: textInput,
      key: toJasprKey(textInput.key),
    ),
    final core.TextNode text => UniboxText(
      node: text,
      key: toJasprKey(text.key),
    ),
    final ComponentNode embed => Component.fragment(<Component>[
      embed.component,
    ], key: toJasprKey(embed.key)),
    final core.EmbedNode embed => throw UnsupportedError(
      'No Jaspr renderer for ${embed.runtimeType}: it carries a '
      '${embed.payload.runtimeType}, and only a ComponentNode can be rendered '
      'by this package.',
    ),
    _ => throw UnsupportedError('No Jaspr renderer for ${node.runtimeType}.'),
  };
}

/// Reports the tree issues of [node], in debug builds only.
///
/// Server rendering has no widget inspector, so warnings go to stdout next to
/// the request log, while errors throw to stop the response before it is wrong.
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
      // ignore: avoid_print
      print('Unibox warning: $issue');
    }

    return true;
  }());
}

/// Renders any Unibox node as a Jaspr [Component].
extension UINodeJasprRenderer on core.UINode {
  /// Returns the Jaspr component for this node.
  ///
  /// ```dart
  /// runApp(const Box(padding: BoxSpacing.all(16)).toComponent());
  /// ```
  Component toComponent() => renderJaspr(this);
}
