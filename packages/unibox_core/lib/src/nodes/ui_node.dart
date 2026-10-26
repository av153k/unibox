/// Base class of every node in the Unibox tree.
///
/// Nodes are immutable descriptions of a piece of UI. Renderers translate them
/// to Flutter widgets or to Jaspr components.
///
/// Custom nodes may extend this class, renderers will report nodes they do not
/// support.
///
/// ## Naming
///
/// A node only carries the `Node` suffix when its bare name would collide with
/// a Flutter widget that consumers import next to this package. `Text`, `Image`,
/// `Stack`, `Positioned` and `Link` all exist in `flutter/widgets.dart`, so
/// those nodes are named `TextNode`, `ImageNode`, `StackNode`,
/// `PositionedNode` and `LinkNode`. `Box` has no Flutter counterpart and
/// stays unsuffixed.
abstract class UINode {
  /// Creates a node.
  const UINode();

  /// The direct child nodes of this node in paint order.
  ///
  /// Leaf nodes return an empty list.
  List<UINode> get children => const <UINode>[];
}
