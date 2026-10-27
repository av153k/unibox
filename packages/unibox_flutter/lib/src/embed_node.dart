import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

/// The signature of an embed implementation that wraps the child of its node.
///
/// An effect that needs the content it decorates — an ink ripple, a hover glow, a
/// hero transition — is a wrapper and not a leaf, so its implementation receives
/// the rendered child instead of standing next to it.
typedef FlutterWidgetEmbedBuilder = Widget Function(Widget child);

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
///   children: <core.UINode>[FlutterWidgetNode(const Placeholder())],
/// );
/// ```
///
/// A node with no implementation this target can draw is reported by
/// [renderFlutter] instead of being skipped, so a tree that was built for another
/// target fails loudly.
final class FlutterWidgetNode extends core.EmbedNode {
  /// Wraps [widget] as a node.
  const FlutterWidgetNode(this.widget, {super.key});

  /// The widget to render.
  final Widget widget;

  @override
  List<Object> get implementations => <Object>[widget];
}
