import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'box.dart';
import 'image_node.dart';
import 'keys.dart';
import 'link_node.dart';
import 'stack_node.dart';
import 'text_input_node.dart';
import 'text_node.dart';

/// Renders [node] as a Jaspr [Component].
///
/// Node types without a web renderer yet throw an [UnsupportedError] so a
/// partially rendered tree can never be shipped silently.
///
/// Every component is created with the key of its node, so reordering a list of
/// nodes keeps each element (and the DOM state it owns) attached to the node it
/// belongs to.
Component renderJaspr(core.UINode node) {
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
      renderJaspr(positioned.child),
    ], key: toJasprKey(positioned.key)),
    final core.TextInputNode textInput => UniboxTextInput(
      node: textInput,
      key: toJasprKey(textInput.key),
    ),
    final core.TextNode text => UniboxText(
      node: text,
      key: toJasprKey(text.key),
    ),
    _ => throw UnsupportedError('No Jaspr renderer for ${node.runtimeType}.'),
  };
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
