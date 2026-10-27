import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// Renders the state a [core.StatefulNode] starts with into a server page.
///
/// A server render has no events and no client store, so this draws the first
/// state and nothing else: `onMount` is not called (a server must not start the
/// work a page starts when it appears), no notification can arrive, and the
/// callbacks the view hands out are inert until a client runtime rebuilds the
/// node in the browser. What it does produce is exactly the markup the first
/// client build will draw, which is what hydration has to match.
///
/// A node whose first state is "loading" therefore renders a page that loads:
/// the useful static shape is one whose store starts with data the server
/// already has. Running the work on the server instead would mean awaiting
/// `onMount` here, which is a decision about server side data, not about
/// rendering.
Component statefulView(core.StatefulNode<Object, core.Store<Object>> node) {
  final core.Store<Object> store = node.createStore();
  final core.NodeView view = node.viewFor(store.state, store);

  final Component tree = renderNode(view.tree);
  final List<Component> overlays = <Component>[
    for (final core.UINode overlay in view.overlays) renderNode(overlay),
  ];

  // Nothing will subscribe on the server, so the store is released as soon as
  // its state has been read. The closures the view handed out refer to it, but
  // a server render never calls them.
  store.dispose();

  if (overlays.isEmpty) {
    return tree;
  }

  return Component.fragment(<Component>[
    tree,
    div(
      overlays,
      styles: const Styles(
        raw: <String, String>{'position': 'fixed', 'inset': '0'},
      ),
    ),
  ]);
}
