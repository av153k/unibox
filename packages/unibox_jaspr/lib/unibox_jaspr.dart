/// Jaspr renderer for the Unibox node tree.
///
/// Exposes `renderJaspr(UINode)` together with the `UINode.toComponent()`
/// extension which turn platform agnostic Unibox nodes into server rendered
/// HTML/CSS components.
///
/// ```dart
/// import 'package:jaspr/jaspr.dart';
/// import 'package:unibox_core/unibox_core.dart';
/// import 'package:unibox_jaspr/unibox_jaspr.dart';
///
/// const card = Box(direction: Axis.vertical, gap: 8, children: [
///   TextNode('Hello'),
/// ]);
///
/// void main() => runApp(card.toComponent());
/// ```
library;

export 'src/embed_node.dart' show ComponentNode;
export 'src/render.dart';
