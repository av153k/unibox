import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

/// The signature of an embed implementation that wraps the child of its node.
///
/// An effect that needs the content it decorates — a ripple, a hover glow, a
/// transition — is a wrapper and not a leaf, so its implementation receives the
/// rendered child instead of standing next to it.
typedef ComponentEmbedBuilder = Component Function(Component child);

/// Renders a Jaspr [Component] inside a Unibox tree.
///
/// The escape hatch for content Unibox does not model: a chart component, a
/// widget from another Dart web package, a hand written `<video>` element.
/// Everything around it still lays out with boxes, but nothing is inherited
/// across it — the component decides what it renders and how.
///
/// ```dart
/// Box(
///   padding: const BoxSpacing.all(16),
///   children: <core.UINode>[ComponentNode(MyChart())],
/// );
/// ```
///
/// A node with no implementation this target can draw is reported by [renderJaspr]
/// instead of being skipped, so a tree that was built for another target fails
/// loudly.
final class ComponentNode extends core.EmbedNode {
  /// Wraps [component] as a node.
  const ComponentNode(this.component, {super.key});

  /// The component to render.
  final Component component;

  @override
  List<Object> get implementations => <Object>[component];
}
