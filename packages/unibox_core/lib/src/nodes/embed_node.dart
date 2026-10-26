import 'ui_node.dart';

/// A node that carries content only one renderer knows how to draw.
///
/// Embeds are the escape hatch for host specific content: a chart from a
/// Flutter package, a video player component, anything that cannot be expressed
/// with Unibox primitives. Core only knows the [payload], so a renderer accepts
/// the payloads it supports and reports the others instead of guessing.
///
/// ```dart
/// // unibox_flutter
/// final class WidgetNode extends EmbedNode {
///   const WidgetNode(this.widget);
///
///   final Widget widget;
///
///   @override
///   Object get payload => widget;
/// }
/// ```
///
/// An embed is opaque to the rest of the model: it has no children, nothing is
/// inherited across it, and a renderer that does not know it throws instead of
/// silently dropping it — an embed is a gap in the abstraction, so it has to be
/// a visible one.
abstract class EmbedNode extends UINode {
  /// Creates an embed.
  const EmbedNode({super.key});

  /// The host specific object this node carries.
  ///
  /// Renderers match on the runtime type of the payload, which is why it is
  /// declared as a plain [Object] rather than a platform type.
  Object get payload;
}
