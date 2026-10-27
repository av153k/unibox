import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';
import 'stylesheet.dart';

/// A Jaspr component that draws a [core.StatefulNode].
///
/// A server draws the state the store starts with and stops there: nothing
/// listens, `onMount` is not called, and the store is released, so rendering a
/// page never starts a request. A browser does the whole job: it keeps the store,
/// calls `onMount`, and redraws the tree whenever the store changes.
///
/// Use it for the part of a page that has to react. Write one subclass, mark it
/// `@client` so that Jaspr also compiles it for the browser, and return the node
/// from [createNode]:
///
/// ```dart
/// @client
/// class ListingsPage extends JasprStateful {
///   const ListingsPage({required this.apiBase, super.key});
///
///   final String apiBase;
///
///   @override
///   core.StatefulNode<Object, core.Store<Object>> createNode() =>
///       StoreFrontPageNode(api: HttpApi(apiBase));
/// }
/// ```
///
/// [createNode] is a method and not a constructor parameter because a `@client`
/// component may only receive simple values — the ones Jaspr can write into the
/// page and read back in the browser. A node is a group of functions, so each
/// side builds it instead of passing it across.
abstract class JasprStateful extends StatefulComponent {
  /// Creates the component. A subclass passes its own serialisable parameters.
  const JasprStateful({super.key});

  /// The node to draw. It is built on the server and in the browser.
  core.StatefulNode<Object, core.Store<Object>> createNode();

  @override
  State<JasprStateful> createState() => JasprStatefulState();
}

class JasprStatefulState extends State<JasprStateful> {
  late final core.StatefulNode<Object, core.Store<Object>> _node = component
      .createNode();

  /// The long-lived store, in a browser only.
  core.Store<Object>? _store;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _store = _node.createStore()
        ..addListener(_changed)
        ..onMount();
    }
  }

  @override
  void dispose() {
    _store
      ?..onUnmount()
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Component build(BuildContext context) {
    final core.Store<Object> store = _store ?? _node.createStore();
    final Component tree = renderNode(_node.viewFor(store.state, store));

    if (!kIsWeb) {
      // A server render reads the first state and lets the store go: nothing
      // will ever notify it.
      store.dispose();
    }

    // A host may use this component as the root of a page, in which case nothing
    // above it opened a stylesheet.
    return withStylesheet(context, tree);
  }
}
