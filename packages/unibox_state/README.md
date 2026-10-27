# unibox_state

Pure Dart state stores for Unibox nodes.

A `StatefulNode` owns a `Store`; this package holds the ready-made one,
`StateStore`. It depends on `unibox_core` and `listen` — flutter.dev's pure Dart
extraction of the listenable family Flutter keeps in `foundation`
([flutter/flutter#149466](https://github.com/flutter/flutter/issues/149466)) — so
one store runs in Flutter, on a server and in a browser, and a `dart test` can
exercise it with no UI at all.

## A store, a view, a node

```dart
// The state is a value: immutable, comparable, easy to assert in a test.
final class SignupState {
  const SignupState({this.email = '', this.pending = false});

  final String email;
  final bool pending;

  SignupState copyWith({String? email, bool? pending}) =>
      SignupState(email: email ?? this.email, pending: pending ?? this.pending);
}

// The store publishes; an equal state notifies nobody.
final class SignupStore extends StateStore<SignupState> {
  SignupStore() : super(const SignupState());

  void setEmail(String email) => state = state.copyWith(email: email);

  Future<void> submit() async {
    state = state.copyWith(pending: true);
    // …the request…
    state = state.copyWith(pending: false);
  }
}

// The view is a function of state, and the node ties the two together.
NodeView signupView(SignupState state, SignupStore store) => (
  tree: TextNode(state.pending ? 'Joining…' : 'Join ${state.email}'),
  overlays: const <UINode>[],
);

final class SignupNode extends StatefulNode<SignupState, SignupStore> {
  SignupNode() : super(create: SignupStore.new, view: signupView);
}
```

`SignupNode().toWidget()` is the standard translator: a renderer creates the
store once, subscribes, calls `onMount`, rebuilds on a notification, and disposes
it on unmount. No per-page renderer code, and no node type per feature.

## What `StateStore` adds to a `Store`

| Member | Meaning |
| --- | --- |
| `state` | the current value, immutable |
| `state = next` | publish, dropping a value equal to the current one |
| `onMount()` | called once by the renderer; start an initial request here, never in a constructor |
| `onUnmount()` | called once before disposal |
| `addListener` / `removeListener` / `dispose` | inherited from `listen`'s `ChangeNotifier` |

## Why `listen` and not `flutter/foundation`

`foundation` is Flutter-only: the core model and the Jaspr renderer cannot import
it, and the point of a store is that the same one runs everywhere. `listen` is
the same API in pure Dart, published by flutter.dev as the first result of moving
Flutter-agnostic types out of Flutter (#149466). When flutter/flutter finishes
that migration the two types will meet; until then `unibox_flutter` bridges to
`ValueListenable` where an application wants `ValueListenableBuilder`.

## Testing

```shell
dart test
```

The suite holds the notifier semantics (a changed state notifies, an equal one
does not, a removed listener stops), the empty lifecycle defaults, and a store
used by a `StatefulNode` from `unibox_core`.

## License

MIT, like the rest of the workspace.
