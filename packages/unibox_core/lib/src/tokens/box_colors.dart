import 'box_color.dart';

/// The palette of names an interface reaches for before it has one of its own.
///
/// Every value is the one Flutter's `Colors` gives the same name — the 500 tone
/// of a hue, and the 300, 500 and 700 tones of the grey ladder — so a tree that
/// names [red] paints the same `#F44336` as the Flutter widgets around it, and
/// the web renderer writes the same hex. The two targets agree by construction,
/// which is the point of the model.
///
/// The palette is a convenience, not a design system. An application with a
/// palette of its own states it in Dart with [BoxColor.rgb] and passes it
/// around, the way `ExamplePalette` does in the example. What the palette
/// deliberately does not carry is a meaning: there is no `primary` or `error`
/// here, because which hue plays that part is the application's decision.
///
/// ```dart
/// const callToAction = Box(
///   backgroundColor: BoxColors.blue,
///   borderRadius: 10,
///   padding: BoxSpacing.symmetric(horizontal: 16, vertical: 10),
///   children: <UINode>[TextNode('Continue', color: BoxColors.white)],
/// );
/// ```
///
/// [BoxColor] keeps [BoxColor.white], [BoxColor.black] and
/// [BoxColor.transparent] next to its constructors, and they are the same values
/// as [white], [black] and [transparent]. The hues live only here: `red`,
/// `green` and `blue` are already the channel getters of a [BoxColor], so a
/// preset cannot take those names.
abstract final class BoxColors {
  /// Opaque white (`#FFFFFF`).
  static const BoxColor white = BoxColor(0xFFFFFFFF);

  /// Opaque black (`#000000`).
  static const BoxColor black = BoxColor(0xFF000000);

  /// No color at all (`#00000000`), for a state that paints nothing.
  static const BoxColor transparent = BoxColor(0x00000000);

  /// A light grey (`#E0E0E0`), for the surface behind content.
  static const BoxColor lightGrey = BoxColor(0xFFE0E0E0);

  /// A mid grey (`#9E9E9E`), the neutral of a plain palette.
  static const BoxColor grey = BoxColor(0xFF9E9E9E);

  /// A dark grey (`#616161`), for text that is not quite black.
  static const BoxColor darkGrey = BoxColor(0xFF616161);

  /// A grey with a blue cast (`#607D8B`), for a cooler palette.
  static const BoxColor blueGrey = BoxColor(0xFF607D8B);

  /// Red (`#F44336`).
  static const BoxColor red = BoxColor(0xFFF44336);

  /// Orange (`#FF9800`).
  static const BoxColor orange = BoxColor(0xFFFF9800);

  /// Yellow (`#FFEB3B`).
  static const BoxColor yellow = BoxColor(0xFFFFEB3B);

  /// Green (`#4CAF50`).
  static const BoxColor green = BoxColor(0xFF4CAF50);

  /// Teal (`#009688`).
  static const BoxColor teal = BoxColor(0xFF009688);

  /// Blue (`#2196F3`).
  static const BoxColor blue = BoxColor(0xFF2196F3);

  /// Indigo (`#3F51B5`).
  static const BoxColor indigo = BoxColor(0xFF3F51B5);

  /// Purple (`#9C27B0`).
  static const BoxColor purple = BoxColor(0xFF9C27B0);

  /// Pink (`#E91E63`).
  static const BoxColor pink = BoxColor(0xFFE91E63);

  /// Brown (`#795548`).
  static const BoxColor brown = BoxColor(0xFF795548);
}
