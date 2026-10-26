import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'box.dart';
import 'image_node.dart';
import 'link_node.dart';
import 'stack_node.dart';
import 'text_input_node.dart';
import 'text_node.dart';

/// Renders [node] as a Jaspr [Component].
///
/// Node types without a web renderer yet throw an [UnsupportedError] so a
/// partially rendered tree can never be shipped silently.
Component renderJaspr(core.UINode node) {
  return switch (node) {
    final core.Box box => UniboxBox(box: box),
    final core.ImageNode image => UniboxImage(node: image),
    final core.LinkNode link => UniboxLink(node: link),
    final core.StackNode stack => UniboxStack(node: stack),
    final core.PositionedNode positioned => renderJaspr(positioned.child),
    final core.TextInputNode textInput => UniboxTextInput(node: textInput),
    final core.TextNode text => UniboxText(node: text),
    _ => throw UnsupportedError(
      'No Jaspr renderer for ${node.runtimeType}.',
    ),
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
