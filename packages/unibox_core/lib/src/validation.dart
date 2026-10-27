import 'enums.dart';
import 'nodes/box.dart';
import 'nodes/link_node.dart';
import 'nodes/positioned_node.dart';
import 'nodes/stack_node.dart';
import 'nodes/ui_node.dart';
import 'tokens/box_semantics.dart';
import 'tokens/box_style.dart';

/// How much a [TreeIssue] matters.
enum TreeIssueSeverity {
  /// The tree still renders, but not as described: an offset is dropped, a
  /// child cannot be reached.
  warning,

  /// At least one target cannot render the tree faithfully.
  error,
}

/// A problem in a node tree that no renderer can compensate for.
///
/// Issues point at the node that caused them and explain how to fix the tree,
/// so a warning printed in debug mode is enough to locate it.
class TreeIssue {
  /// Creates an issue for [node].
  const TreeIssue({
    required this.node,
    required this.message,
    this.severity = TreeIssueSeverity.warning,
  });

  /// The node the issue belongs to.
  final UINode node;

  /// What is wrong and how to fix it.
  final String message;

  /// How much the issue matters.
  final TreeIssueSeverity severity;

  /// Whether this issue is an [TreeIssueSeverity.error].
  bool get isError => severity == TreeIssueSeverity.error;

  @override
  String toString() => message;
}

/// Checks the tree rooted at [root] for constructs that do not survive
/// rendering.
///
/// The checks are pure and cheap, so both renderers run them inside an
/// assertion: a broken tree is reported in debug builds and costs nothing in
/// release builds. Call it directly to lint a tree in a test or a command line
/// tool.
///
/// Detected issues:
/// * a [PositionedNode] whose parent is not a [StackNode], which silently drops
///   its offsets,
/// * a [LinkNode] nested inside another [LinkNode], which is invalid HTML and
///   navigates twice,
/// * a box that scrolls along its main axis while distributing its children
///   with [Box.mainAlign], which pushes overflowing children out of reach,
/// * a list item whose parent is not a list, which is invalid HTML and which no
///   assistive technology can announce as a list.
List<TreeIssue> validateTree(UINode root) {
  final List<TreeIssue> issues = <TreeIssue>[];
  _validate(root, parent: null, inLink: false, issues: issues);
  return issues;
}

/// Walks [node] and records every issue of the subtree into [issues].
void _validate(
  UINode node, {
  required UINode? parent,
  required bool inLink,
  required List<TreeIssue> issues,
}) {
  if (node is PositionedNode && parent is! StackNode) {
    issues.add(
      TreeIssue(
        node: node,
        message:
            'A PositionedNode is only placed by a StackNode, but its parent is '
            '${parent?.runtimeType ?? 'the root'}. Its offsets are ignored and '
            'the child renders at its natural position.',
      ),
    );
  }

  var nestedInLink = inLink;

  if (node is LinkNode) {
    if (inLink) {
      issues.add(
        TreeIssue(
          node: node,
          severity: TreeIssueSeverity.error,
          message:
              'A LinkNode cannot contain another LinkNode: HTML forbids nested '
              '<a> elements, and the double navigation is not something either '
              'target can undo. Move the inner link out of the outer one.',
        ),
      );
    }
    nestedInLink = true;
  }

  if (node is Box) {
    final BoxStyle style = node.computedStyle;
    final MainAlign? mainAlign = style.mainAlign;

    if (style.overflow == Overflow.scroll &&
        mainAlign != null &&
        mainAlign != MainAlign.start) {
      issues.add(
        TreeIssue(
          node: node,
          message:
              'A box that scrolls along its main axis cannot distribute its '
              'children with mainAlign: ${mainAlign.name}. The children that '
              'overflow are pushed out of reach in CSS and out of the viewport '
              'in Flutter. Use MainAlign.start and let the children scroll.',
        ),
      );
    }
  }

  if (node is Box && node.semantics?.element == BoxElement.li) {
    final BoxElement? parentElement = parent is Box
        ? parent.semantics?.element
        : null;

    if (parentElement != BoxElement.ul && parentElement != BoxElement.ol) {
      issues.add(
        TreeIssue(
          node: node,
          severity: TreeIssueSeverity.error,
          message:
              'A box with BoxElement.li has to be a child of a box with '
              'BoxElement.ul or BoxElement.ol, but its parent is '
              '${parent?.runtimeType ?? 'the root'}. An <li> anywhere else is '
              'invalid HTML and is not announced as an item of a list.',
        ),
      );
    }
  }

  for (final UINode child in node.children) {
    _validate(child, parent: node, inLink: nestedInLink, issues: issues);
  }
}
