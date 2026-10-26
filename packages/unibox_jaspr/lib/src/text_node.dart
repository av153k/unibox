import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'values.dart';

/// Renders a [core.TextNode] as a styled `<span>`.
///
/// Only the typography tokens set on the node are emitted, so the text keeps
/// inheriting font family, line height and everything else from the page — the
/// same way a Flutter `Text` inherits from `DefaultTextStyle`.
///
/// A [core.TextNode.maxLines] is rendered with the `-webkit-line-clamp` box,
/// which is the only way to truncate after a number of lines in CSS. Without
/// `maxLines` a [core.TextOverflow.ellipsis] truncates the single line instead.
class UniboxText extends StatelessComponent {
  /// Creates a renderer for [node].
  const UniboxText({required this.node, super.key});

  /// The node being rendered.
  final core.TextNode node;

  @override
  Component build(BuildContext context) {
    return span([Component.text(node.text)], styles: toTextStyles(node));
  }
}
