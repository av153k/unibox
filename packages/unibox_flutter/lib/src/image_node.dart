import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'values.dart';

/// Renders a [core.ImageNode] as a Flutter [Image].
///
/// An image that fails to load keeps the declared size instead of throwing, so
/// a broken source never breaks the surrounding layout. The [core.ImageNode.alt]
/// text is exposed as the semantic label for screen readers.
class UniboxImage extends StatelessWidget {
  /// Creates a renderer for [node].
  const UniboxImage({required this.node, super.key});

  /// The node being rendered.
  final core.ImageNode node;

  @override
  Widget build(BuildContext context) {
    final core.ImageFit? fit = node.fit;
    final double? borderRadius = node.borderRadius;

    final Widget image = Image(
      image: toImageProvider(node.src),
      width: node.width,
      height: node.height,
      fit: fit == null ? null : toBoxFit(fit),
      semanticLabel: node.alt.isEmpty ? null : node.alt,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) => SizedBox(width: node.width, height: node.height),
    );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}
