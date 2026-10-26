/// Pure Dart layout primitives shared by every Unibox renderer.
///
/// This library is intentionally free of platform dependencies: it never
/// imports `dart:ui`, Flutter or Jaspr, so it can be consumed from command line
/// tools, servers and both UI targets alike.
///
/// The public API is composed of:
/// * style tokens ([BoxColor], [BoxSpacing], [BoxStyle], [BoxBorder],
///   [BoxShadow]),
/// * layout enums ([Axis], [MainAlign], [CrossAlign], [Overflow], [ImageFit],
///   [FontWeight], [TextAlign], [TextOverflow]),
/// * the immutable node tree rooted in `UINode`.
library;

export 'src/enums.dart';
export 'src/tokens/box_border.dart';
export 'src/tokens/box_color.dart';
export 'src/tokens/box_shadow.dart';
export 'src/tokens/box_spacing.dart';
export 'src/tokens/box_style.dart';
