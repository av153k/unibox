/// A point inside a box, in logical pixels.
///
/// The model has no `Offset`: that type belongs to a host, and so does the screen a
/// box sits on. A point is two numbers, and a box is the only frame the tree owns —
/// which is why the coordinate a callback reports is the local one, the one Flutter
/// (`localPosition`) and a browser (`offsetX`/`offsetY`) can both produce exactly.
final class BoxPoint {
  /// Creates a point at [x] and [y] logical pixels inside the box.
  const BoxPoint(this.x, this.y);

  /// The distance from the left edge of the box.
  final double x;

  /// The distance from the top edge of the box.
  final double y;

  @override
  bool operator ==(Object other) =>
      other is BoxPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'BoxPoint($x, $y)';
}

/// What pressed a box.
///
/// The kinds both targets can name: Flutter through `PointerDeviceKind`, the web
/// through `pointerType`, and both through the keyboard activation that has no
/// pointer at all. Anything finer — pressure, tilt, a modifier key — is a device
/// fact rather than a model one.
enum BoxPointerKind {
  /// A finger.
  touch,

  /// A mouse or a trackpad.
  mouse,

  /// A stylus or a pen.
  pen,

  /// A keyboard activation: `Enter` or `Space` on a focused box.
  keyboard,

  /// A device the host could not name.
  unknown,
}

/// Where and with what a press landed on a box.
///
/// It is an event rather than a pair of numbers so that what a press carries can
/// grow — the pointer kind is already here, and a modifier or a double tap would
/// arrive as a field instead of a new callback.
final class BoxTapEvent {
  /// Creates an event at [position], pressed by [pointer].
  const BoxTapEvent({
    required this.position,
    this.pointer = BoxPointerKind.unknown,
  });

  /// Where the press landed, inside the box.
  final BoxPoint position;

  /// What pressed it.
  final BoxPointerKind pointer;

  @override
  bool operator ==(Object other) =>
      other is BoxTapEvent &&
      other.position == position &&
      other.pointer == pointer;

  @override
  int get hashCode => Object.hash(position, pointer);

  @override
  String toString() => 'BoxTapEvent(position: $position, pointer: $pointer)';
}
