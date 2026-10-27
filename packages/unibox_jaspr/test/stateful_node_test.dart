import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_jaspr/unibox_jaspr.dart';

import 'support/harness.dart';

/// A store written by hand, with the counters a server render has to leave at zero.
final class _Store implements core.Store<int> {
  _Store() : _value = 0;

  int _value;
  final List<void Function()> _listeners = <void Function()>[];

  int mounts = 0;
  bool disposed = false;

  @override
  int get state => _value;

  @override
  void addListener(void Function() listener) => _listeners.add(listener);

  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);

  @override
  void onMount() => mounts++;

  @override
  void onUnmount() {}

  @override
  void dispose() => disposed = true;

  void increment() {
    _value++;
    for (final void Function() listener in List<void Function()>.of(
      _listeners,
    )) {
      listener();
    }
  }
}

_Store? _lastStore;
_Store _createStore() => _lastStore = _Store();

core.NodeView _view(int state, _Store store) => (
  tree: core.Box(
    onTap: store.increment,
    children: <core.UINode>[core.TextNode('Count: $state')],
  ),
  overlays: const <core.UINode>[],
);

final class _Node extends core.StatefulNode<int, _Store> {
  _Node() : super(create: _createStore, view: _view);
}

/// A node whose first state already asks for an overlay.
final class _OpenStore implements core.Store<bool> {
  @override
  bool get state => true;

  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  void onMount() {}

  @override
  void onUnmount() {}

  @override
  void dispose() {}
}

core.NodeView _openView(bool state, _OpenStore store) => (
  tree: const core.TextNode('Page'),
  overlays: const <core.UINode>[core.TextNode('Details')],
);

final class _OpenNode extends core.StatefulNode<bool, _OpenStore> {
  _OpenNode() : super(create: _OpenStore.new, view: _openView);
}

void main() {
  testComponents('renders the state the store starts with', (tester) async {
    pumpNode(tester, _Node());

    expect(find.text('Count: 0'), findsOneComponent);
  });

  test('does not run onMount during a server render', () {
    renderJaspr(_Node());

    expect(_lastStore!.mounts, 0);
  });

  test('releases the store once its state has been read', () {
    renderJaspr(_Node());

    expect(_lastStore!.disposed, isTrue);
  });

  testComponents('renders an overlay the first state asks for', (tester) async {
    pumpNode(tester, _OpenNode());

    expect(find.text('Page'), findsOneComponent);
    expect(find.text('Details'), findsOneComponent);
  });
}
