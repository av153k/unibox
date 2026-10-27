import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// Renders a [core.StatefulNode]: one store and the tree of its state.
///
/// The widget creates the store once, when it is mounted, subscribes to it,
/// calls [core.Store.onMount] and disposes it on unmount — so a rebuild with a
/// node of the same type and key keeps the state, and a different key starts
/// again.
///
/// The view is rendered in place, so it inherits the typography and the layout
/// of the boxes around it. A view draws one tree; an overlay is not part of the
/// model yet.
class FlutterStateful extends StatefulWidget {
  /// Creates a renderer for [node].
  const FlutterStateful({required this.node, super.key});

  /// The node being rendered.
  final core.StatefulNode<Object, core.Store<Object>> node;

  @override
  State<FlutterStateful> createState() => FlutterStatefulState();
}

class FlutterStatefulState extends State<FlutterStateful> {
  late core.Store<Object> _store;

  @override
  void initState() {
    super.initState();
    _store = widget.node.createStore()..addListener(_changed);
    _store.onMount();
  }

  @override
  void dispose() {
    _store.onUnmount();
    _store.removeListener(_changed);
    _store.dispose();
    super.dispose();
  }

  void _changed() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return renderNode(widget.node.viewFor(_store.state, _store));
  }
}
