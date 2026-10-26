import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'box.dart';
import 'image_node.dart';
import 'text_node.dart';

/// Renders [node] as a Flutter [Widget].
///
/// ```dart
/// runApp(UniboxApp(child: renderFlutter(myNode)));
/// ```
///
/// Throws an [UnsupportedError] when [node] has no Flutter renderer yet.
Widget renderFlutter(core.UINode node) {
  return switch (node) {
    final core.Box box => UniboxBox(box: box),
    final core.TextNode text => UniboxText(node: text),
    final core.ImageNode image => UniboxImage(node: image),
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
