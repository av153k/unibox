import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// Follows the destination of a [core.LinkNode].
typedef LinkOpener = FutureOr<void> Function(String url);

/// Configures how [core.LinkNode]s open their destination on Flutter.
///
/// Flutter has no built-in browser, so the host application decides what
/// following a link means, e.g. with `url_launcher`:
///
/// ```dart
/// UniboxLinkScope(
///   open: (String url) => launchUrl(Uri.parse(url)),
///   child: renderFlutter(node),
/// );
/// ```
///
/// Without a scope, links still call their own
/// [core.LinkNode.onTap] and behave like any other tappable region.
/// [core.LinkNode.newTab] only affects the web renderer.
class UniboxLinkScope extends InheritedWidget {
  /// Creates a scope that opens links with [open].
  const UniboxLinkScope({required this.open, required super.child, super.key});

  /// Follows [url] the way the host application navigates.
  final LinkOpener open;

  /// The opener of the closest enclosing scope, or `null` when there is none.
  static LinkOpener? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UniboxLinkScope>()?.open;
  }

  @override
  bool updateShouldNotify(UniboxLinkScope oldWidget) => open != oldWidget.open;
}

/// Renders a [core.LinkNode] as a tappable region around its child.
class UniboxLink extends StatelessWidget {
  /// Creates a renderer for [node].
  const UniboxLink({required this.node, super.key});

  /// The node being rendered.
  final core.LinkNode node;

  @override
  Widget build(BuildContext context) {
    final LinkOpener? open = UniboxLinkScope.maybeOf(context);

    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            node.onTap?.call();
            open?.call(node.url);
          },
          child: renderFlutter(node.child),
        ),
      ),
    );
  }
}
