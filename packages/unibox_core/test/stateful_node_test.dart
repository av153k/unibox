import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

/// A store written by hand, with no package behind it.
final class _Counter implements Store<int> {
  _Counter([this._value = 0]);

  final int _value;
  final List<void Function()> _listeners = <void Function()>[];

  int mounts = 0;
  int unmounts = 0;
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
  void onUnmount() => unmounts++;

  @override
  void dispose() {
    disposed = true;
    _listeners.clear();
  }
}

UINode _counterView(int state, _Counter store) => TextNode('$state');

/// The spelling an application uses: a node of its own over a store of its own.
final class _CounterNode extends StatefulNode<int, _Counter> {
  _CounterNode() : super(create: _Counter.new, view: _counterView);
}

void main() {
  group('StatefulNode', () {
    test('creates the store when the renderer asks for it', () {
      final node = _CounterNode();

      final Store<int> first = node.createStore();
      final Store<int> second = node.createStore();

      expect(first, isA<_Counter>());
      expect(first.state, 0);
      expect(identical(first, second), isFalse);
    });

    test('draws the view of the state it is given', () {
      final node = _CounterNode();
      final _Counter store = node.createStore() as _Counter;

      final UINode view = node.viewFor(3, store);

      expect(view, isA<TextNode>());
      expect((view as TextNode).text, '3');
    });

    test('hands the typed store to the view', () {
      final node = _CounterNode();
      final Store<int> store = node.createStore();
      Object? seen;

      node.viewFor(1, store);

      // The view is written against _Counter, not against Store, so a missing
      // cast would fail here rather than in a renderer.
      expect(() => seen = store, returnsNormally);
      expect(seen, isA<_Counter>());
    });

    test('has no children of its own, because the view builds them', () {
      expect(_CounterNode().children, isEmpty);
    });

    test('validates like any other node', () {
      final tree = Box(children: <UINode>[_CounterNode()]);

      expect(validateTree(tree), isEmpty);
    });

    test('is reachable through the erased type a renderer uses', () {
      final StatefulNode<Object, Store<Object>> node = _CounterNode();

      expect(node.createStore().state, 0);
      expect(node.viewFor(2, node.createStore()), isA<TextNode>());
    });

    test('keeps the key of the node it is given', () {
      final node = StatefulNode<int, _Counter>(
        key: 'counter',
        create: _Counter.new,
        view: _counterView,
      );

      expect(node.key, 'counter');
    });
  });
}
