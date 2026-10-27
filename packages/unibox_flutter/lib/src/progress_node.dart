import 'package:flutter/material.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'values.dart';

/// Draws a [core.ProgressNode] with Flutter's circular indicator.
///
/// The colours, the diameter and the stroke come from the node, not from the
/// ambient theme, so the ring is the one the tree describes. Turning while the
/// value is unknown is the indicator's own animation.
class FlutterProgress extends StatelessWidget {
  /// Creates the indicator for [node].
  const FlutterProgress({required this.node, super.key});

  /// The node being drawn.
  final core.ProgressNode node;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: node.size,
      height: node.size,
      child: CircularProgressIndicator(
        value: node.value,
        color: toColor(node.color),
        backgroundColor: toColor(node.trackColor),
        strokeWidth: node.strokeWidth,
        strokeCap: StrokeCap.round,
        semanticsLabel: node.semanticsLabel,
        semanticsValue: node.value == null
            ? null
            : '${((node.value ?? 0) * 100).round()}%',
      ),
    );
  }
}
