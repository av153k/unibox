/// Pure Dart layout primitives shared by every Unibox renderer.
///
/// This library is intentionally free of platform dependencies: it never
/// imports `dart:ui`, Flutter or Jaspr, so it can be consumed from command line
/// tools, servers and both UI targets alike.
///
/// The public API is composed of:
/// * style tokens ([BoxColor], `BoxSpacing`, `BoxStyle`, ...),
/// * layout enums (`Axis`, `MainAlign`, `CrossAlign`, ...),
/// * the immutable node tree rooted in `UINode`.
library;
