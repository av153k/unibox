import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'values.dart';

/// Renders a [core.TextNode] as a Flutter [Text].
///
/// Only the typography tokens set on the node are passed to Flutter, so the
/// surrounding `DefaultTextStyle` keeps providing everything else — including
/// the style a box installs from its `textStyle`.
class UniboxText extends StatelessWidget {
  /// Creates a renderer for [node].
  const UniboxText({required this.node, super.key});

  /// The node being rendered.
  final core.TextNode node;

  @override
  Widget build(BuildContext context) {
    final core.TextAlign? align = node.textAlign;
    final core.TextOverflow? overflow = node.overflow;

    return Text(
      node.text,
      style: toTextStyle(node.computedStyle),
      textAlign: align == null ? null : toTextAlign(align),
      maxLines: node.maxLines,
      overflow: overflow == null ? null : toTextOverflow(overflow),
    );
  }
}
