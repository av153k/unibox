import '../enums.dart';
import 'ui_node.dart';

/// A network or bundled image.
class ImageNode extends UINode {
  /// Creates an image node.
  const ImageNode(
    this.src, {
    super.key,
    this.alt = '',
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  /// The location of the image.
  ///
  /// Absolute URLs are loaded from the network, relative paths refer to assets
  /// bundled with the Flutter application or served by the website.
  final String src;

  /// Alternative text used by screen readers and when loading fails.
  final String alt;

  /// The width in logical pixels, or `double.infinity` to expand.
  final double? width;

  /// The height in logical pixels, or `double.infinity` to expand.
  final double? height;

  /// How the image fills its bounds.
  ///
  /// `null` means [resolvedFit].
  final ImageFit? fit;

  /// The fit both renderers apply; [ImageFit.scaleDown] when the node names none.
  ///
  /// The default belongs to the model, because a renderer would otherwise fall
  /// back to its own platform: Flutter's `Image` scales a picture down and never
  /// enlarges it, while a browser stretches it over its box. An image that
  /// declares no fit therefore used to be squashed on the web and letterboxed in
  /// Flutter, which is a difference the tree never asked for.
  ImageFit get resolvedFit => fit ?? ImageFit.scaleDown;

  /// The corner radius in logical pixels.
  final double? borderRadius;
}
