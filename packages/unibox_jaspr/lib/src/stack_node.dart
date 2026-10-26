import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';
import 'values.dart';

/// Renders a [core.StackNode] as a layering container.
///
/// The element is a relative grid whose children all share one cell, so they
/// overlap each other and are painted in source order (last on top). The
/// container still sizes to its largest child, matching a Flutter `Stack`, and
/// it never clips its content, matching `Clip.none`.
///
/// A child that is not a [core.PositionedNode] is wrapped in a grid cell, which
/// is the CSS equivalent of placing it at the top start corner of the stack.
class UniboxStack extends StatelessComponent {
  /// Creates a renderer for [node].
  const UniboxStack({required this.node, super.key});

  /// The node being rendered.
  final core.StackNode node;

  @override
  Component build(BuildContext context) {
    return div(
      <Component>[
        for (final core.UINode child in node.children) _stackChild(child),
      ],
      styles: toStackStyles(node),
    );
  }
}

/// Renders a [core.PositionedNode] as an absolutely positioned element.
///
/// A positioned node without any offset keeps its natural place, exactly like a
/// `Positioned` widget that was never needed: it is rendered as a regular stack
/// child. Rendering the node on its own falls back to its child, since there is
/// no stack to position it in.
class UniboxPositioned extends StatelessComponent {
  /// Creates a renderer for [node].
  const UniboxPositioned({required this.node, super.key});

  /// The node being rendered.
  final core.PositionedNode node;

  @override
  Component build(BuildContext context) {
    final Component child = renderJaspr(node.child);

    if (node.isUnpositioned) {
      return div(<Component>[child], styles: toStackChildStyles());
    }

    return div(<Component>[child], styles: toPositionedStyles(node));
  }
}

/// Renders [node] as a child of a stack.
Component _stackChild(core.UINode node) {
  if (node is core.PositionedNode) {
    return UniboxPositioned(node: node);
  }
  return div(<Component>[renderJaspr(node)], styles: toStackChildStyles());
}
