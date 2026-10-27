import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// Renders a [core.StatefulNode]: one store, the view of its state, and the
/// overlays that view asks for.
///
/// The widget creates the store once, when it is mounted, subscribes to it,
/// calls [core.Store.onMount] and disposes it on unmount — so a rebuild with an
/// equal node keeps the state, and a different `key` starts again.
///
/// The view is rendered with the rest of the tree. Each overlay is rendered
/// through [renderFlutter] into the root [Overlay], which is what lets an
/// overlay escape the clipping and scrolling of the boxes around it; a muted
/// barrier below it keeps the pointer away from the page. Focus containment,
/// `Escape` and the leave animation are not part of this layer yet.
///
/// A view that emits an overlay needs an [Overlay] above the tree — every
/// `MaterialApp` or `WidgetsApp` provides one. A stateful node whose view emits
/// none renders without it.
class UniboxStateful extends StatefulWidget {
  /// Creates a renderer for [node].
  const UniboxStateful({required this.node, super.key});

  /// The node being rendered.
  final core.StatefulNode<Object, core.Store<Object>> node;

  @override
  State<UniboxStateful> createState() => _UniboxStatefulState();
}

class _UniboxStatefulState extends State<UniboxStateful> {
  final OverlayPortalController _overlay = OverlayPortalController(
    debugLabel: 'UniboxStateful',
  );

  late core.Store<Object> _store;

  @override
  void initState() {
    super.initState();
    _store = widget.node.createStore()..addListener(_changed);
    _store.onMount();
    _scheduleOverlaySync();
  }

  @override
  void didUpdateWidget(UniboxStateful oldWidget) {
    super.didUpdateWidget(oldWidget);

    // The store belongs to this element, so a new node instance with the same
    // type and key keeps the state and only changes the view.
    _scheduleOverlaySync();
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
    _scheduleOverlaySync();
  }

  /// Shows or hides the overlay portal once the state settles.
  ///
  /// `show` and `hide` cannot run during a build, and the overlays are only
  /// known after the view is built, so the answer is applied on the next frame.
  void _scheduleOverlaySync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final bool hasOverlays = widget.node
          .viewFor(_store.state, _store)
          .overlays
          .isNotEmpty;
      if (hasOverlays == _overlay.isShowing) {
        return;
      }
      if (hasOverlays) {
        _overlay.show();
      } else {
        _overlay.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final core.NodeView view = widget.node.viewFor(_store.state, _store);

    return OverlayPortal(
      controller: _overlay,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (BuildContext context) =>
          _StatefulOverlay(node: widget.node, store: _store),
      child: renderNode(view.tree),
    );
  }
}

/// The overlay of one stateful node: a barrier and the trees the view asked for.
class _StatefulOverlay extends StatelessWidget {
  const _StatefulOverlay({required this.node, required this.store});

  final core.StatefulNode<Object, core.Store<Object>> node;
  final core.Store<Object> store;

  @override
  Widget build(BuildContext context) {
    final core.NodeView view = node.viewFor(store.state, store);

    if (view.overlays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: ModalBarrier(dismissible: false)),
        for (final core.UINode overlay in view.overlays)
          // An overlay is a root of its own: it is inserted above the tree, so
          // it installs the model's typography the way renderFlutter does.
          renderFlutter(overlay),
      ],
    );
  }
}
