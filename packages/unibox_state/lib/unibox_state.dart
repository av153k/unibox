/// Pure Dart state stores for Unibox nodes.
///
/// A `StatefulNode` owns a `Store`; this package provides the ready made one,
/// `StateStore`, on top of `package:listen` — flutter.dev's pure Dart
/// extraction of the listenable family Flutter keeps in `foundation`
/// (flutter/flutter#149466). One store therefore serves Flutter, a server
/// render and a browser, which is exactly why it is not built on
/// `package:flutter/foundation.dart`.
library;

export 'src/state_store.dart';
