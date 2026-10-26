import 'box_color.dart';

/// A drop shadow painted behind a box.
final class BoxShadow {
  /// Creates a drop shadow.
  const BoxShadow({
    this.color = BoxColor.black,
    this.offsetX = 0,
    this.offsetY = 2,
    this.blurRadius = 4,
    this.spreadRadius = 0,
  });

  /// The shadow color, including its opacity.
  final BoxColor color;

  /// The horizontal offset in logical pixels.
  final double offsetX;

  /// The vertical offset in logical pixels.
  final double offsetY;

  /// The blur radius in logical pixels.
  final double blurRadius;

  /// The spread radius in logical pixels.
  final double spreadRadius;

  @override
  bool operator ==(Object other) =>
      other is BoxShadow &&
      other.color == color &&
      other.offsetX == offsetX &&
      other.offsetY == offsetY &&
      other.blurRadius == blurRadius &&
      other.spreadRadius == spreadRadius;

  @override
  int get hashCode =>
      Object.hash(color, offsetX, offsetY, blurRadius, spreadRadius);

  @override
  String toString() =>
      'BoxShadow(offsetX: $offsetX, offsetY: $offsetY, blurRadius: $blurRadius, '
      'spreadRadius: $spreadRadius, color: $color)';
}
