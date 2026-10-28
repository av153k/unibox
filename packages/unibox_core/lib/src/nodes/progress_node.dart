import '../tokens/box_color.dart';
import 'ui_node.dart';

/// A circular progress indicator: a ring that fills to a [value], or turns while
/// the answer is not known.
///
/// ```dart
/// const ProgressNode(); // indeterminate, while a request is pending
/// const ProgressNode(value: 0.4, color: BoxColors.blue);
/// ```
///
/// It is a node of its own and not a styled box because an indeterminate ring
/// *moves*, and the model describes a look, not a timeline: each renderer turns
/// the ring with what it has (a Flutter indicator, a CSS animation), and the
/// numbers below — the size, the stroke and the colours — are the part both
/// agree on. How the arc grows and shrinks while it turns is the platform's, and
/// is outside the parity contract.
class ProgressNode extends UINode {
  /// Creates a progress indicator.
  const ProgressNode({
    super.key,
    this.value,
    this.color = defaultColor,
    this.trackColor = BoxColor.transparent,
    this.size = defaultSize,
    this.strokeWidth = defaultStrokeWidth,
    this.semanticsLabel,
  }) : assert(value == null || (value >= 0 && value <= 1));

  /// The colour of the ring when a node names none.
  static const BoxColor defaultColor = BoxColor.black;

  /// The diameter, in logical pixels, when a node names none: the 48 of Material.
  static const double defaultSize = 48;

  /// The thickness of the ring, in logical pixels, when a node names none.
  static const double defaultStrokeWidth = 4;

  /// How much of the work is done, from `0` to `1`, or `null` when it is not
  /// known and the ring turns.
  final double? value;

  /// The colour of the arc.
  final BoxColor color;

  /// The colour of the ring behind the arc; transparent by default.
  final BoxColor trackColor;

  /// The diameter of the indicator, in logical pixels.
  final double size;

  /// The thickness of the ring, in logical pixels.
  final double strokeWidth;

  /// What a screen reader announces: "Loading", "Uploading photos".
  final String? semanticsLabel;

  /// Whether the indicator turns because its progress is unknown.
  bool get isIndeterminate => value == null;
}
