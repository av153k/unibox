import 'box_color.dart';

/// A uniform border drawn around a box.
final class BoxBorder {
  /// Creates a border with the given [width] and [color].
  const BoxBorder({this.width = 1, this.color = BoxColor.black});

  /// A border that occupies no space and is not painted.
  const BoxBorder.none() : width = 0, color = BoxColor.transparent;

  /// The border thickness in logical pixels.
  final double width;

  /// The border color.
  final BoxColor color;

  /// Whether the border has a visible thickness.
  bool get isVisible => width > 0;

  @override
  bool operator ==(Object other) =>
      other is BoxBorder && other.width == width && other.color == color;

  @override
  int get hashCode => Object.hash(width, color);

  @override
  String toString() => 'BoxBorder(width: $width, color: $color)';
}
