import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

/// Renders a Flutter [Widget] inside a Unibox tree.
///
/// The escape hatch for content Unibox does not model: a chart from a package, a
/// platform view, a video player. Everything around it still lays out with boxes,
/// but nothing is inherited across it — the widget brings its own styling, and
/// its own typography is not taken over by the enclosing `DefaultTextStyle`
/// unless the widget reads it.
///
/// ```dart
/// Box(
///   padding: const BoxSpacing.all(16),
///   children: <core.UINode>[WidgetNode(const Placeholder())],
/// );
/// ```
///
/// A node whose payload is not a [Widget] is reported by
/// [renderFlutter] instead of being skipped, so a tree that was built for
/// another target fails loudly.
final class WidgetNode extends core.EmbedNode {
  /// Wraps [widget] as a node.
  const WidgetNode(this.widget, {super.key});

  /// The widget to render.
  final Widget widget;

  @override
  Object get payload => widget;
}
