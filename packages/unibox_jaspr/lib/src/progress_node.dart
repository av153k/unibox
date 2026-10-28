import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'values.dart';

/// The name of the rule that turns an indeterminate ring.
const String progressSpinAnimation = 'unibox-progress-spin';

/// Draws a [core.ProgressNode] as a ring in CSS: a conic gradient cut by a
/// radial mask, so the stroke is the one the node states.
///
/// Determinate, the gradient stops at the value. Indeterminate, a quarter of the
/// ring turns under a `@keyframes` rule. The ends of the arc are square, where the
/// Flutter indicator rounds them, and the way the arc grows while it turns is the
/// platform's: both are outside the parity contract.
class JasprProgress extends StatelessComponent {
  /// Creates the ring for [node].
  const JasprProgress({required this.node, super.key});

  /// The node being drawn.
  final core.ProgressNode node;

  @override
  Component build(BuildContext context) {
    final double fraction = node.value ?? 0.25;
    final String arc = (fraction * 100).toStringAsFixed(2);
    final String color = _css(node.color);
    final String track = _css(node.trackColor);
    final String hole = '${node.strokeWidth}px';
    final String mask =
        'radial-gradient(farthest-side, transparent calc(100% - $hole), '
        '#000 calc(100% - $hole))';

    final Component ring = div(
      const <Component>[],
      attributes: <String, String>{
        'role': 'progressbar',
        'aria-valuemin': '0',
        'aria-valuemax': '1',
        if (node.value case final double value) 'aria-valuenow': '$value',
        if (node.semanticsLabel case final String label) 'aria-label': label,
      },
      styles: Styles(
        raw: <String, String>{
          'box-sizing': 'border-box',
          'width': '${node.size}px',
          'height': '${node.size}px',
          'flex-shrink': '0',
          'border-radius': '50%',
          'background': 'conic-gradient($color $arc%, $track 0)',
          'mask': mask,
          '-webkit-mask': mask,
          if (node.isIndeterminate)
            'animation': '$progressSpinAnimation 1s linear infinite',
        },
      ),
    );

    if (!node.isIndeterminate) {
      return ring;
    }

    return Component.fragment(<Component>[
      Style(
        styles: <StyleRule>[
          StyleRule.keyframes(
            name: progressSpinAnimation,
            styles: <String, Styles>{
              'to': Styles(
                raw: <String, String>{'transform': 'rotate(360deg)'},
              ),
            },
          ),
        ],
      ),
      ring,
    ]);
  }
}

/// A colour as CSS: a role as its custom property, anything else as its channels.
String _css(core.BoxColor color) =>
    cssRoleReference(color) ?? toCssColor(color).value;
