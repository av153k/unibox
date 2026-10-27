import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_jaspr/unibox_jaspr.dart';

/// The smallest store that satisfies the contract.
final class _Store implements core.Store<int> {
  @override
  int get state => 0;

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

core.NodeView _view(int state, _Store store) =>
    (tree: core.TextNode('$state'), overlays: const <core.UINode>[]);

final class _Stateful extends core.StatefulNode<int, _Store> {
  _Stateful() : super(create: _Store.new, view: _view);
}

void main() {
  test('reports a stateful node instead of skipping it', () {
    // The store runs in this target too, but a view that reacts to it needs a
    // client runtime, which this renderer does not have yet. Throwing keeps the
    // gap visible instead of rendering a page that silently does nothing.
    expect(
      () => renderJaspr(_Stateful()),
      throwsA(
        isA<UnsupportedError>().having(
          (UnsupportedError error) => error.message,
          'message',
          contains('client runtime'),
        ),
      ),
    );
  });
}
