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
  final ImageFit? fit;

  /// The corner radius in logical pixels.
  final double? borderRadius;
}
