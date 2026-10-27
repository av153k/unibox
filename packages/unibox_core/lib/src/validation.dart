import 'enums.dart';
import 'nodes/box.dart';
import 'nodes/embed_node.dart';
import 'nodes/link_node.dart';
import 'nodes/positioned_node.dart';
import 'nodes/stack_node.dart';
import 'nodes/ui_node.dart';
import 'tokens/box_semantics.dart';
import 'tokens/box_style.dart';
import 'tokens/box_transition.dart';

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
/// * a list item whose parent is not a list, and a caption whose parent is not a
///   figure, both of which are invalid HTML and name nothing where they stand,
/// * an embed that carries no implementation at all, which no renderer can draw
///   and which would otherwise vanish from the page,
/// * a transition declared on a state style instead of the resting one, which no
///   renderer applies,
/// * a transition with a duration that changes nothing,
/// * an opacity outside the `0` to `1` that both targets accept.
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

  if (node is Box && node.semantics?.element == BoxElement.figcaption) {
    final BoxElement? parentElement = parent is Box
        ? parent.semantics?.element
        : null;

    if (parentElement != BoxElement.figure) {
      issues.add(
        TreeIssue(
          node: node,
          severity: TreeIssueSeverity.error,
          message:
              'A box with BoxElement.figcaption has to be a child of a box with '
              'BoxElement.figure, but its parent is '
              '${parent?.runtimeType ?? 'the root'}. A <figcaption> anywhere else '
              'is invalid HTML and names nothing.',
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

  if (node is Box) {
    final BoxTransition? transition = node.computedStyle.transition;
    final double? opacity = node.computedStyle.opacity;

    if (opacity != null && (opacity < 0 || opacity > 1)) {
      issues.add(
        TreeIssue(
          node: node,
          message:
              'A box declares an opacity of $opacity, which is outside the 0 to 1 '
              'range both targets accept. Below 0 paints nothing visible and '
              'above 1 is the same as solid.',
        ),
      );
    }

    for (final TreeIssue issue in _transitionIssues(node, transition)) {
      issues.add(issue);
    }

    if (transition != null && transition.duration <= Duration.zero) {
      issues.add(
        TreeIssue(
          node: node,
          message:
              'A box declares a transition of ${transition.duration}, which '
              'changes nothing: a transition needs a positive duration.',
        ),
      );
    }

    for (final BoxState state in BoxState.values) {
      if (node.stateStyle(state)?.transition != null) {
        issues.add(
          TreeIssue(
            node: node,
            message:
                'A box declares its transition in the ${state.name} style instead '
                'of the resting one, so no renderer applies it: a transition says '
                'how a change eases, and the change belongs to the state, not the '
                'duration.',
          ),
        );
      }
    }
  }

  if (node is EmbedNode && node.implementations.isEmpty) {
    issues.add(
      TreeIssue(
        node: node,
        severity: TreeIssueSeverity.error,
        message:
            'An ${node.runtimeType} carries no implementation, so no renderer can '
            'draw it and every target reports it. Give the node one payload per '
            'renderer that has to render the tree.',
      ),
    );
  }

  for (final UINode child in node.children) {
    _validate(child, parent: node, inLink: nestedInLink, issues: issues);
  }
}

/// The issues of the transition parts of [box], if it declares any.
///
/// A part has to name a look, no look may be named twice, and the four things a
/// box paints have to share one timing: a single `BoxDecoration` interpolates as a
/// unit on Flutter, so paint properties that ease at different speeds would need
/// layered decorations — which the tree expresses by nesting a box, and which the
/// renderer must not approximate silently.
List<TreeIssue> _transitionIssues(Box box, BoxTransition? transition) {
  if (transition == null || transition.parts.isEmpty) {
    return const <TreeIssue>[];
  }

  final List<TreeIssue> issues = <TreeIssue>[];
  final Map<BoxLook, BoxTransitionPart> named = <BoxLook, BoxTransitionPart>{};

  for (final BoxTransitionPart part in transition.parts) {
    if (part.looks.isEmpty) {
      issues.add(
        TreeIssue(
          node: box,
          severity: TreeIssueSeverity.error,
          message:
              'A BoxTransitionPart names no look, so it eases nothing. Name the '
              'looks it should cover, e.g. {BoxLook.transform}.',
        ),
      );
    }

    if (part.duration <= Duration.zero) {
      issues.add(
        TreeIssue(
          node: box,
          message:
              'A BoxTransitionPart eases ${part.looks.map((BoxLook l) => l.name)} '
              'over ${part.duration}, which changes nothing.',
        ),
      );
    }

    for (final BoxLook look in part.looks) {
      if (named.containsKey(look)) {
        issues.add(
          TreeIssue(
            node: box,
            severity: TreeIssueSeverity.error,
            message:
                'Two BoxTransitionParts ease ${look.name}, so it is ambiguous '
                'which one applies. Name each look once.',
          ),
        );
      }
      named[look] = part;
    }
  }

  const Set<BoxLook> paint = <BoxLook>{
    BoxLook.backgroundColor,
    BoxLook.borderColor,
    BoxLook.borderRadius,
    BoxLook.shadow,
  };
  final Set<BoxTransitionTiming> paintTimings = <BoxTransitionTiming>{
    for (final BoxLook look in paint) transition.timingOf(look),
  };

  if (paintTimings.length > 1) {
    issues.add(
      TreeIssue(
        node: box,
        severity: TreeIssueSeverity.error,
        message:
            'The paint of a box (background, border colour, radius, shadow) eases '
            'as one on Flutter, so its looks have to share a timing. Give them one '
            'part, or nest a box and let each one ease its own paint.',
      ),
    );
  }

  return issues;
}
