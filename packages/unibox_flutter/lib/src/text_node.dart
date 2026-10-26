import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'values.dart';

/// Renders a [core.TextNode] as a Flutter [Text].
///
/// Only the typography tokens set on the node are passed to Flutter, so the
/// surrounding `DefaultTextStyle` keeps providing everything else.
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
      style: toTextStyle(node),
      textAlign: align == null ? null : toTextAlign(align),
      maxLines: node.maxLines,
      overflow: overflow == null ? null : toTextOverflow(overflow),
    );
  }
}

/// Builds the [TextStyle] of [node], or `null` when it sets no typography.
TextStyle? toTextStyle(core.TextNode node) {
  final core.FontWeight? weight = node.fontWeight;
  final core.BoxColor? color = node.color;

  if (node.fontSize == null && weight == null && color == null) {
    return null;
  }

  return TextStyle(
    fontSize: node.fontSize,
    fontWeight: weight == null ? null : toFontWeight(weight),
    color: color == null ? null : toColor(color),
  );
}
