import 'box_color.dart';

/// The ink a press spreads across a box: Material's ripple.
///
/// A ripple is motion rather than a look, so it is deliberately outside the
/// appearance contract in `unibox_testing`, which compares what a renderer
/// *declares*. What the model states is the ink and how long the spread takes; each
/// renderer draws the motion with what its platform has — an ink response in
/// Flutter, a CSS pseudo-element on the web — and the two are close rather than
/// identical.
///
/// ```dart
/// const Box(
///   onTap: open,
///   semantics: BoxSemantics(role: BoxRole.button, label: 'Open'),
///   ripple: BoxRipple(),
/// )
/// ```
final class BoxRipple {
  /// Creates a ripple in [color] that takes [duration] to spread.
  const BoxRipple({this.color = defaultColor, this.duration = defaultDuration});

  /// The ink of a resting ripple: black at 12%, Material's state-layer weight.
  static const BoxColor defaultColor = BoxColor(0x1F000000);

  /// How long the ink takes to spread over the box.
  static const Duration defaultDuration = Duration(milliseconds: 450);

  /// The colour the ink is painted in.
  final BoxColor color;

  /// How long the ink takes to spread.
  final Duration duration;

  @override
  bool operator ==(Object other) =>
      other is BoxRipple && other.color == color && other.duration == duration;

  @override
  int get hashCode => Object.hash(color, duration);

  @override
  String toString() => 'BoxRipple(color: $color, duration: $duration)';
}
