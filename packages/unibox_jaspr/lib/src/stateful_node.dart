import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'stateful_component.dart';

/// Renders a [core.StatefulNode] wherever it sits in a tree.
///
/// A node in the middle of a page is a component like the page itself, so it goes
/// through [JasprStateful] rather than being drawn once: a server reads the first
/// state and lets the store go — `onMount` is not called, because a server must not
/// start the work a page starts when it appears — and a browser keeps the store,
/// calls `onMount`, and redraws that node when the store changes.
///
/// Drawing the first state and stopping would have been enough while a page was
/// static, and it is exactly what made a ripple never move on the web: the store a
/// press wrote to had been disposed before the press could happen.
Component statefulView(core.StatefulNode<Object, core.Store<Object>> node) {
  return JasprStatefulNode(node: node);
}
