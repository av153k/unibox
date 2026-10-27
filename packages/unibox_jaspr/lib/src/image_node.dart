import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'values.dart';

/// Renders a [core.ImageNode] as an `<img>`.
///
/// `src` and `alt` become the matching HTML attributes, so screen readers and
/// broken image placeholders behave like they do on any other web page. The
/// image keeps the node's size: numbers are logical pixels, `double.infinity`
/// fills the available space, and a missing dimension keeps the natural aspect
/// ratio. `fit` maps to `object-fit` and `borderRadius` to `border-radius`.
///
/// In Flutter an image is a leaf box, so the element is rendered as a block
/// rather than the default inline image: the picture then occupies exactly its
/// bounds instead of adding a line box with a baseline gap around it.
class JasprImage extends StatelessComponent {
  /// Creates a renderer for [node].
  const JasprImage({required this.node, super.key});

  /// The node being rendered.
  final core.ImageNode node;

  @override
  Component build(BuildContext context) {
    return img(src: node.src, alt: node.alt, styles: toImageStyles(node));
  }
}
