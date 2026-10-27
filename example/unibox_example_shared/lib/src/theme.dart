import 'package:unibox_core/unibox_core.dart';

/// The palette of the example.
///
/// The colors are declared once because both renderers paint the same pages:
/// Flutter translates them to a `Color`, the web renderer to a CSS color.
abstract final class ExamplePalette {
  /// The accent of the banner, the button and the checkbox.
  static const BoxColor accent = BoxColor.rgb(0x2D, 0x6C, 0xF3);

  /// The accent while the pointer is over the button.
  static const BoxColor accentHover = BoxColor.rgb(0x1D, 0x4E, 0xD8);

  /// The accent while the button is pressed.
  static const BoxColor accentPressed = BoxColor.rgb(0x16, 0x3E, 0xB0);

  /// The tint behind the item of the page that is open.
  static const BoxColor accentSurface = BoxColor.rgb(0xE8, 0xEF, 0xFD);

  /// The background of the card and of the navigation bar.
  static const BoxColor surface = BoxColor.white;

  /// The color of the page behind the card.
  static const BoxColor canvas = BoxColor.rgb(0xF3, 0xF4, 0xF6);

  /// The default text color.
  static const BoxColor text = BoxColor.rgb(0x11, 0x18, 0x27);

  /// The color of supporting text.
  static const BoxColor muted = BoxColor.rgb(0x6B, 0x72, 0x80);

  /// The color of borders, and of the button while it is not ready.
  static const BoxColor border = BoxColor.rgb(0xE5, 0xE7, 0xEB);

  /// The color of the confirmation message.
  static const BoxColor success = BoxColor.rgb(0x15, 0x80, 0x3D);

  /// The background of the confirmation message.
  static const BoxColor successSurface = BoxColor.rgb(0xEC, 0xFD, 0xF5);

  /// The color of the panel standing in for the map.
  static const BoxColor mapSurface = BoxColor.rgb(0xDF, 0xEA, 0xD6);

  /// The border of the map panel.
  static const BoxColor mapLine = BoxColor.rgb(0xC2, 0xD4, 0xB7);

  /// The label in the middle of the map panel.
  static const BoxColor mapLabel = BoxColor.rgb(0x3F, 0x5A, 0x3A);

  /// The tint of the square that stands in for the photo of a listing.
  static const List<BoxColor> listingTints = <BoxColor>[
    BoxColor.rgb(0xFD, 0xE8, 0xD3),
    BoxColor.rgb(0xE1, 0xEB, 0xFA),
    BoxColor.rgb(0xF3, 0xE3, 0xF1),
    BoxColor.rgb(0xE3, 0xF2, 0xE8),
    BoxColor.rgb(0xFA, 0xF0, 0xD5),
    BoxColor.rgb(0xE8, 0xE6, 0xF7),
  ];
}

/// The typography of the example.
///
/// Typography is the one thing a box passes down to its children, so a page
/// states it once per area and the text nodes only repeat a token they
/// override. The result is identical in Flutter and on the web: a
/// `DefaultTextStyle` on one side, plain CSS inheritance on the other.
abstract final class ExampleType {
  /// The line height of the example, as a multiple of the font size.
  ///
  /// The unitless form is the only one that means the same thing in CSS and in
  /// Flutter, so every text of the example gets the same leading on both
  /// targets. A font *family* is deliberately left out: a family is a host
  /// decision — the Flutter app inherits the platform font from its theme, the
  /// web app declares a stack on the document — and both platforms end up on
  /// their own UI font, which is the closest a family can get across two
  /// applications.
  static const double lineHeight = 1.45;

  /// The body text of the example.
  ///
  /// This is the style a page installs, so everything below it inherits the
  /// line height and only overrides size, weight and colour.
  static const BoxTextStyle body = BoxTextStyle(
    fontSize: 14,
    color: ExamplePalette.text,
    lineHeight: lineHeight,
  );

  /// Supporting text, such as hints and the status line.
  static const BoxTextStyle muted = BoxTextStyle(
    fontSize: 13,
    color: ExamplePalette.muted,
  );

  /// The title of a card or of a page.
  static const BoxTextStyle title = BoxTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: ExamplePalette.text,
  );

  /// The name of the example, at the start of the navigation bar.
  static const BoxTextStyle brand = BoxTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: ExamplePalette.text,
  );

  /// A navigation item that is not the page that is open.
  static const BoxTextStyle nav = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.medium,
    color: ExamplePalette.muted,
  );

  /// The navigation item of the page that is open.
  static const BoxTextStyle navCurrent = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.semiBold,
    color: ExamplePalette.accent,
  );

  /// The label of the primary button.
  static const BoxTextStyle button = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.semiBold,
    color: ExamplePalette.surface,
  );

  /// The link under the button.
  static const BoxTextStyle link = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.medium,
    color: ExamplePalette.accent,
  );

  /// The name of a listing.
  static const BoxTextStyle listingName = BoxTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.semiBold,
    color: ExamplePalette.text,
  );

  /// The rent of a listing.
  static const BoxTextStyle listingPrice = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.semiBold,
    color: ExamplePalette.accent,
  );

  /// The label in the middle of the map panel.
  static const BoxTextStyle map = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.medium,
    color: ExamplePalette.mapLabel,
  );
}
