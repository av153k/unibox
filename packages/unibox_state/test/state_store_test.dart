import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_state/unibox_state.dart';

final class _CounterStore extends StateStore<int> {
  _CounterStore() : super(0);

  int mounts = 0;
  int unmounts = 0;

  void increment() => state = state + 1;

  void set(int value) => state = value;

  @override
  void onMount() => mounts++;

  @override
  void onUnmount() => unmounts++;
}

/// A store with no lifecycle of its own, to pin the defaults.
final class _PlainStore extends StateStore<String> {
  _PlainStore() : super('first');

  void set(String value) => state = value;
}

NodeView _counterView(int state, _CounterStore store) =>
    (tree: TextNode('$state'), overlays: <UINode>[]);

final class _CounterNode extends StatefulNode<int, _CounterStore> {
  _CounterNode() : super(create: _CounterStore.new, view: _counterView);
}

void main() {
  group('StateStore', () {
    test('starts with the state it is given', () {
      expect(_CounterStore().state, 0);
    });

    test('notifies a listener when the state changes', () {
      final store = _CounterStore();
      var calls = 0;
      store.addListener(() => calls++);

      store.increment();
      store.increment();

      expect(store.state, 2);
      expect(calls, 2);
    });

    test('drops a state equal to the current one', () {
      final store = _CounterStore();
      var calls = 0;
      store.addListener(() => calls++);

      store.set(0);
      store.set(1);
      store.set(1);

      expect(calls, 1);
      expect(store.state, 1);
    });

    test('stops notifying a removed listener', () {
      final store = _CounterStore();
      var calls = 0;
      void listener() => calls++;

      store.addListener(listener);
      store.increment();
      store.removeListener(listener);
      store.increment();

      expect(calls, 1);
    });

    test('leaves the lifecycle empty by default', () {
      final store = _PlainStore();

      expect(store.onMount, returnsNormally);
      expect(store.onUnmount, returnsNormally);
      expect(store.state, 'first');
    });

    test('is the store a stateful node draws', () {
      final node = _CounterNode();
      final store = node.createStore() as _CounterStore;
      var calls = 0;
      store.addListener(() => calls++);

      store.increment();
      final NodeView view = node.viewFor(store.state, store);

      expect((view.tree as TextNode).text, '1');
      expect(calls, 1);
    });

    test('is a Store, so the erased renderer type accepts it', () {
      final StatefulNode<Object, Store<Object>> node = _CounterNode();

      final Store<Object> store = node.createStore();
      expect(store.state, 0);
      expect((node.viewFor(4, store).tree as TextNode).text, '4');
    });
  });
}
