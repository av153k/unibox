# Changelog

## Unreleased

- The first release of the package: `StateStore<S>`, a `Store` that holds one
  immutable state value and notifies its listeners when it is replaced.
- `state = next` is the only way to publish, and an equal state notifies nobody,
  so a rebuild follows a change of the description rather than a call.
- `onMount` and `onUnmount` are the lifecycle hooks a renderer calls, which is
  where an initial request starts — a server render reads the first state without
  running it.
- The listeners, `dispose` and the notification rules come from
  `package:listen`, flutter.dev's pure Dart extraction of Flutter's listenable
  family, so one store serves Flutter, a server and a browser.
