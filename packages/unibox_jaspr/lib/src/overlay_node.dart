import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';
import 'stylesheet.dart';
import 'values.dart';

/// Draws a [core.OverlayNode] as a fixed layer over the page.
///
/// A server render has no `Escape`, no pointer handling and no focus to move, so
/// this is the overlay's *look*: a fixed layer, the barrier, the content and
/// where it sits. It is never drawn in the flow of its parent — an overlay on
/// the web is a layer or nothing. The interaction (dismissing, focus) arrives
/// with the client runtime.
class JasprOverlay extends StatelessComponent {
  /// Creates a renderer for [node].
  const JasprOverlay({required this.node, super.key});

  /// The node being rendered.
  final core.OverlayNode node;

  @override
  Component build(BuildContext context) {
    final String alignment = switch (node.alignment) {
      core.OverlayAlignment.center => 'center',
      core.OverlayAlignment.top => 'flex-start',
      core.OverlayAlignment.bottom => 'flex-end',
    };

    final Styles layer = Styles(
      raw: <String, String>{
        'position': 'fixed',
        'inset': '0',
        'display': 'flex',
        'align-items': alignment,
        'justify-content': 'center',
      },
    );
    final Styles barrier = Styles(
      raw: <String, String>{
        'position': 'absolute',
        'inset': '0',
        'background-color': toCssColor(node.barrierColor).value,
      },
    );
    final UniboxStylesheet? sheet = UniboxStylesheetScope.of(context);

    return div(
      <Component>[
        div(
          const <Component>[],
          classes: _className(sheet, 'overlay-barrier', barrier),
          styles: sheet == null ? barrier : null,
        ),
        div(<Component>[renderNode(node.child)]),
      ],
      attributes: const <String, String>{
        'role': 'dialog',
        'aria-modal': 'true',
      },
      classes: _className(sheet, 'overlay', layer),
      styles: sheet == null ? layer : null,
    );
  }

  /// The class of [styles] in [sheet], or `null` when there is no sheet to put it
  /// in.
  static String? _className(
    UniboxStylesheet? sheet,
    String kind,
    Styles styles,
  ) => sheet?.classFor(
    kind,
    declarationsOf(styles),
    (String name) => <StyleRule>[
      StyleRule(selector: Selector.className(name), styles: styles),
    ],
  );
}
