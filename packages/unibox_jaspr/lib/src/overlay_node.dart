import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';
import 'values.dart';

/// Draws an overlay as a fixed layer over the page.
///
/// A server render has no `Escape`, no pointer handling and no focus to move, so
/// this is the overlay's *look*: a fixed layer, the barrier, the content and
/// where it sits. It is never drawn in the flow of its parent — an overlay on
/// the web is a layer or nothing. The interaction (dismissing, focus) arrives
/// with the client runtime.
Component overlayView(core.OverlayNode node) {
  final String alignment = switch (node.alignment) {
    core.OverlayAlignment.center => 'center',
    core.OverlayAlignment.top => 'flex-start',
    core.OverlayAlignment.bottom => 'flex-end',
  };

  return div(
    <Component>[
      div(
        const <Component>[],
        styles: Styles(
          raw: <String, String>{
            'position': 'absolute',
            'inset': '0',
            'background-color': toCssColor(node.barrierColor).value,
          },
        ),
      ),
      div(<Component>[renderNode(node.child)]),
    ],
    attributes: const <String, String>{'role': 'dialog', 'aria-modal': 'true'},
    styles: Styles(
      raw: <String, String>{
        'position': 'fixed',
        'inset': '0',
        'display': 'flex',
        'align-items': alignment,
        'justify-content': 'center',
      },
    ),
  );
}
