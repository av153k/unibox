import 'ui_node.dart';

/// A container that layers its [children] on top of each other.
///
/// Use [PositionedNode] children to place them at exact offsets.
class StackNode extends UINode {
  /// Creates a stack node.
  const StackNode({this.children = const <UINode>[], this.width, this.height});

  /// The layered children, painted in order (last on top).
  @override
  final List<UINode> children;

  /// The width of the stack in logical pixels, or `double.infinity`.
  final double? width;

  /// The height of the stack in logical pixels, or `double.infinity`.
  final double? height;
}
