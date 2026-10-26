import 'package:jaspr/jaspr.dart';

/// Translates the key of a node into a Jaspr [Key].
///
/// An unkeyed node stays unkeyed, so it keeps the default positional reuse.
Key? toJasprKey(Object? key) => key == null ? null : ValueKey<Object>(key);
