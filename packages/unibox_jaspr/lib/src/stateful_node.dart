import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// Renders the state a [core.StatefulNode] starts with into a server page.
///
/// A server render has no events and no client store, so this draws the first
/// state and stops: `onMount` is not called (a server must not start the work a
/// page starts when it appears), no notification can arrive, and the callbacks
/// the view hands out are inert until a client runtime rebuilds the node in the
/// browser. What it does produce is exactly the markup the first client build
/// will draw, which is what hydration has to match.
///
/// A node whose first state is `loading` therefore renders a page that loads:
/// the useful static shape is one whose store starts with data the server
/// already has.
Component statefulView(core.StatefulNode<Object, core.Store<Object>> node) {
  final core.Store<Object> store = node.createStore();
  final Component tree = renderNode(node.viewFor(store.state, store));

  // Nothing will subscribe on the server, so the store is released as soon as
  // its state has been read. The closures the view handed out refer to it, but
  // a server render never calls them.
  store.dispose();

  return tree;
}
