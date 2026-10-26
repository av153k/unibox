/// An immutable set of insets expressed in logical pixels.
///
/// Used for both `padding` and `margin` of a box.
final class BoxSpacing {
  /// Creates spacing with individual edges.
  const BoxSpacing({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  /// Creates spacing with the same value on every edge.
  const BoxSpacing.all(double value)
    : top = value,
      right = value,
      bottom = value,
      left = value;

  /// Creates spacing with equal horizontal and vertical values.
  const BoxSpacing.symmetric({double horizontal = 0, double vertical = 0})
    : top = vertical,
      right = horizontal,
      bottom = vertical,
      left = horizontal;

  /// Creates spacing by naming only the edges that need a value.
  const BoxSpacing.only({
    double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
  }) : this(top: top, right: right, bottom: bottom, left: left);

  /// No spacing on any edge.
  static const BoxSpacing zero = BoxSpacing();

  /// The top inset.
  final double top;

  /// The right inset.
  final double right;

  /// The bottom inset.
  final double bottom;

  /// The left inset.
  final double left;

  /// The combined left and right insets.
  double get horizontal => left + right;

  /// The combined top and bottom insets.
  double get vertical => top + bottom;

  /// Whether every edge is `0`.
  bool get isZero => top == 0 && right == 0 && bottom == 0 && left == 0;

  /// Whether the top and bottom insets match.
  bool get hasUniformVertical => top == bottom;

  /// Whether the left and right insets match.
  bool get hasUniformHorizontal => left == right;

  /// Returns a copy of this spacing with the given edges replaced.
  BoxSpacing copyWith({
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) {
    return BoxSpacing(
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BoxSpacing &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom &&
      other.left == left;

  @override
  int get hashCode => Object.hash(top, right, bottom, left);

  @override
  String toString() =>
      'BoxSpacing(top: $top, right: $right, bottom: $bottom, left: $left)';
}
