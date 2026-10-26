/// Base class of every node in the Unibox tree.
///
/// Nodes are immutable descriptions of a piece of UI. Renderers translate them
/// to Flutter widgets or to Jaspr components.
///
/// Custom nodes may extend this class, renderers will report nodes they do not
/// support.
abstract class UINode {
  /// Creates a node.
  const UINode();

  /// The direct child nodes of this node in paint order.
  ///
  /// Leaf nodes return an empty list.
  List<UINode> get children => const <UINode>[];
}
