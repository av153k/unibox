import '../enums.dart';

/// How one look of a box becomes another.
///
/// A [BoxStyle] describes a box at rest; a [BoxState] style describes it in a
/// state. Without a transition the second replaces the first, and the eye sees a
/// jump. A transition turns that jump into an interpolation of the *paint* tokens
/// — background, border colour, corner radius and shadow — which is the set both
/// targets animate with the same result: CSS spells it as a set of `transition`
/// properties, Flutter as an implicit animation of the decoration.
///
/// Two things are deliberately outside it. Layout never animates: a transition on
/// a width or a gap would move everything around the box on one target and not on
/// the other, and a moving layout is not a look. And the border *width* is not in
/// the set for the same reason: CSS animates it as a layout change, Flutter as a
/// paint change.
///
/// ```dart
/// const Box(
///   stateStyles: <BoxState, BoxStyle>{
///     BoxState.hover: BoxStyle(backgroundColor: BoxColor.grey),
///   },
///   transition: BoxTransition(duration: Duration(milliseconds: 150)),
/// );
/// ```
final class BoxTransition {
  /// Creates a transition of [duration] with [curve].
  const BoxTransition({required this.duration, this.curve = BoxCurve.ease});

  /// How long the look takes to change.
  ///
  /// A duration of zero or less renders as no animation at all; `validateTree`
  /// reports it, because a `Duration` cannot be checked in a const constructor.
  final Duration duration;

  /// The easing applied over [duration].
  final BoxCurve curve;

  /// Creates a copy of this transition with the given fields replaced.
  BoxTransition copyWith({Duration? duration, BoxCurve? curve}) {
    return BoxTransition(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BoxTransition &&
      other.duration == duration &&
      other.curve == curve;

  @override
  int get hashCode => Object.hash(duration, curve);

  @override
  String toString() => 'BoxTransition(duration: $duration, curve: $curve)';
}
