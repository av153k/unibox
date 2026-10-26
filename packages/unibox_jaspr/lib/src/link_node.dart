import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// Renders a [core.LinkNode] as a semantic `<a>` element.
///
/// The `href` keeps the link working without JavaScript: middle clicks, the
/// context menu, prefetching and search engines all behave like they do on any
/// other website. [core.LinkNode.newTab] sets `target="_blank"` together with
/// `rel="noopener noreferrer"`, so the opened page never gets a handle on the
/// opener or its referrer.
///
/// [core.LinkNode.onTap] is called from a plain `click` listener instead of the
/// component's `onClick`, because `onClick` would call `preventDefault()` and
/// stop the browser from following the link.
class UniboxLink extends StatelessComponent {
  /// Creates a renderer for [node].
  const UniboxLink({required this.node, super.key});

  /// The node being rendered.
  final core.LinkNode node;

  @override
  Component build(BuildContext context) {
    final core.TapCallback? onTap = node.onTap;
    final bool newTab = node.newTab;

    return a(
      <Component>[renderNode(node.child)],
      href: node.url,
      target: newTab ? Target.blank : null,
      attributes: newTab ? _newTabAttributes : null,
      events: onTap == null
          ? null
          : <String, EventCallback>{'click': (event) => onTap()},
    );
  }
}

/// Attributes that make a `target="_blank"` link safe.
const Map<String, String> _newTabAttributes = <String, String>{
  'rel': 'noopener noreferrer',
};
