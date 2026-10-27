import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// A Jaspr component that draws a [core.StatefulNode] and, in a browser, drives
/// its store.
///
/// An application subclasses it once per island, marks the subclass `@client`
/// and returns its node from [createNode]:
///
/// ```dart
/// @client
/// class ListingsIsland extends UniboxStateful {
///   const ListingsIsland({required this.apiBase, super.key});
///
///   final String apiBase;
///
///   @override
///   core.StatefulNode<Object, core.Store<Object>> createNode() =>
///       StoreFrontPageNode(api: HttpApi(apiBase));
/// }
/// ```
///
/// The difference between the two targets is [kIsWeb]:
///
/// * in a browser the store is created once, subscribed to, `onMount` is
///   called, and a notification rebuilds the tree;
/// * during a server render the store is created only to read its first state:
///   nothing subscribes, `onMount` never runs, and the store is released — so a
///   request is never started by a server render.
///
/// The markup a server writes is therefore the first state, which is what the
/// client has to hydrate. Reacting in a browser needs the Jaspr client build:
/// an island is Dart code compiled to JavaScript, not a tree passed in markup,
/// which is why the node is created here and not handed over as a parameter.
abstract class UniboxStateful extends StatefulComponent {
  /// Creates the component. A subclass passes its own serialisable parameters.
  const UniboxStateful({super.key});

  /// The node this island draws, built in the browser when the component runs
  /// there.
  core.StatefulNode<Object, core.Store<Object>> createNode();

  @override
  State<UniboxStateful> createState() => _UniboxStatefulState();
}

class _UniboxStatefulState extends State<UniboxStateful> {
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

    return tree;
  }
}
