import 'package:flutter/widgets.dart';

/// Translates the key of a node into a Flutter [Key].
///
/// An unkeyed node stays unkeyed, so it keeps the default positional reuse.
Key? toFlutterKey(Object? key) => key == null ? null : ValueKey<Object>(key);
