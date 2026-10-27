import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

import 'support/harness.dart';

/// A store with no package behind it, so the renderer is tested on its own.
final class _Store implements core.Store<int> {
  _Store() : _value = 0;

  int _value;
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

  bool get hasListeners => _listeners.isNotEmpty;

  void increment() {
    _value++;
    for (final void Function() listener in List<void Function()>.of(
      _listeners,
    )) {
      listener();
    }
  }
}

core.NodeView _counterView(int state, _Store store) => (
  tree: core.Box(
    children: <core.UINode>[
      core.Box(
        onTap: store.increment,
        children: <core.UINode>[core.TextNode('Count: $state')],
      ),
    ],
  ),
  overlays: const <core.UINode>[],
);

final class _CounterNode extends core.StatefulNode<int, _Store> {
  _CounterNode() : super(create: _createdStore, view: _counterView);
}

/// The store the node factory made last, so a test can look at its lifecycle.
_Store? _lastStore;
_RequestStore? _lastRequest;

_Store _createdStore() => _lastStore = _Store();

/// A store whose view emits an overlay while it is true.
final class _DialogStore implements core.Store<bool> {
  _DialogStore() : _open = false;

  bool _open;
  final List<void Function()> _listeners = <void Function()>[];

  @override
  bool get state => _open;

  @override
  void addListener(void Function() listener) => _listeners.add(listener);

  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);

  @override
  void onMount() {}

  @override
  void onUnmount() {}

  @override
  void dispose() {}

  void set(bool open) {
    if (open == _open) {
      return;
    }
    _open = open;
    for (final void Function() listener in List<void Function()>.of(
      _listeners,
    )) {
      listener();
    }
  }
}

core.NodeView _dialogView(bool open, _DialogStore store) => (
  tree: core.Box(
    onTap: () => store.set(true),
    children: const <core.UINode>[core.TextNode('Open details')],
  ),
  overlays: <core.UINode>[
    if (open)
      core.Box(
        children: <core.UINode>[
          core.TextNode('Details'),
          core.Box(
            onTap: () => store.set(false),
            children: const <core.UINode>[core.TextNode('Close')],
          ),
        ],
      ),
  ],
);

final class _DialogNode extends core.StatefulNode<bool, _DialogStore> {
  _DialogNode() : super(create: _DialogStore.new, view: _dialogView);
}

/// A store whose first state is a pending request that finishes later.
final class _RequestStore implements core.Store<String> {
  final Completer<String> _answer = Completer<String>();
  final List<void Function()> _listeners = <void Function()>[];

  String _state = 'pending';

  @override
  String get state => _state;

  @override
  void addListener(void Function() listener) => _listeners.add(listener);

  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);

  @override
  void onMount() {
    _answer.future.then((String value) {
      _state = value;
      for (final void Function() listener in List<void Function()>.of(
        _listeners,
      )) {
        listener();
      }
    });
  }

  @override
  void onUnmount() {}

  @override
  void dispose() {}

  void answer(String value) => _answer.complete(value);
}

core.NodeView _requestView(String state, _RequestStore store) =>
    (tree: core.TextNode(state), overlays: const <core.UINode>[]);

_RequestStore _createdRequest() => _lastRequest = _RequestStore();

final class _RequestNode extends core.StatefulNode<String, _RequestStore> {
  _RequestNode() : super(create: _createdRequest, view: _requestView);
}

/// Renders [node] under the root overlay a Material application provides.
Future<void> pumpStateful(WidgetTester tester, core.UINode node) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(
            builder: (BuildContext context) => Center(
              child: KeyedSubtree(key: nodeKey, child: renderFlutter(node)),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('UniboxStateful', () {
    testWidgets('draws the view of the state the store starts with', (
      tester,
    ) async {
      await pumpStateful(tester, _CounterNode());

      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('rebuilds the view when the store publishes a state', (
      tester,
    ) async {
      await pumpStateful(tester, _CounterNode());

      await tester.tap(find.text('Count: 0'));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('mounts the store once and disposes it on unmount', (
      tester,
    ) async {
      await pumpStateful(tester, _CounterNode());
      final _Store store = _lastStore!;

      expect(store.mounts, 1);
      expect(store.hasListeners, isTrue);
      expect(store.unmounts, 0);

      await tester.pumpWidget(const SizedBox());

      expect(store.unmounts, 1);
      expect(store.disposed, isTrue);
      expect(store.hasListeners, isFalse);
    });

    testWidgets('keeps the state when an equal node rebuilds', (tester) async {
      await pumpStateful(tester, _CounterNode());
      await tester.tap(find.text('Count: 0'));
      await tester.pump();

      await pumpStateful(tester, _CounterNode());

      expect(find.text('Count: 1'), findsOneWidget);
      expect(_lastStore!.mounts, 1);
    });

    testWidgets('shows and removes the overlays the view asks for', (
      tester,
    ) async {
      await pumpStateful(tester, _DialogNode());

      expect(find.text('Details'), findsNothing);

      await tester.tap(find.text('Open details'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Details'), findsNothing);
    });

    testWidgets('replaces the pending tree when the request answers', (
      tester,
    ) async {
      await pumpStateful(tester, _RequestNode());

      expect(find.text('pending'), findsOneWidget);

      final _RequestStore store = _lastRequest!;
      store.answer('ready');
      await tester.pump();
      await tester.pump();

      expect(find.text('ready'), findsOneWidget);
      expect(find.text('pending'), findsNothing);
    });

    testWidgets('renders without an overlay ancestor while it asks for none', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: KeyedSubtree(
              key: nodeKey,
              child: renderFlutter(_CounterNode()),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
    });
  });
}
