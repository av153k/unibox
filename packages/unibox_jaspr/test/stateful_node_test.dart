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

core.UINode _view(int state, _Store store) => core.Box(
  onTap: store.increment,
  children: <core.UINode>[core.TextNode('Count: $state')],
);

final class _Node extends core.StatefulNode<int, _Store> {
  _Node() : super(create: _createStore, view: _view);
}

/// What an application writes: one subclass that says which node to build.
final class _CounterPage extends UniboxStateful {
  const _CounterPage();

  @override
  core.StatefulNode<Object, core.Store<Object>> createNode() => _Node();
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

  testComponents('a client component renders the state the store starts with', (
    tester,
  ) async {
    tester.pumpComponent(const _CounterPage());

    expect(find.text('Count: 0'), findsOneComponent);
  });

  testComponents('a client component does not start work on the server', (
    tester,
  ) async {
    tester.pumpComponent(const _CounterPage());

    // kIsWeb is false under the VM, which is exactly the server path.
    expect(_lastStore!.mounts, 0);
    expect(_lastStore!.disposed, isTrue);
  });
}
