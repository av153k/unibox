import 'package:unibox_core/unibox_core.dart';

import 'material_palette.dart';

/// A Material icon: one glyph of an icon font, centred in a square, drawn as a
/// [Box] around a [TextNode].
///
/// ```dart
/// MaterialIcon('home');                         // by ligature name
/// MaterialIcon.codePoint(0xe88a, size: 20);     // by code point
/// MaterialIcon('delete', color: palette.error, label: 'Delete');
/// ```
///
/// An icon is text set in an icon font, so it needs no node of its own and no
/// embed: both renderers already draw a text with a family, a size and a colour,
/// and a glyph follows the same tokens as any other text. That is also why the
/// icon recolours with `color` and scales with `size`, which an image cannot.
///
/// **The font is the host's.** Like any font file it is an asset the model does
/// not carry: the application bundles `Material Symbols Outlined` (or
/// `Material Icons`) and declares it for Flutter, with an `@font-face` for the
/// web. [fontFamily] names it. A host without the font draws the ligature name as
/// plain text, which is the sign that it is missing.
///
/// **Accessibility.** An icon next to a text is decoration and is hidden from
/// assistive technology; pass [label] when it stands alone (an icon button) and it
/// is announced instead.
final class MaterialIcon extends Box {
  /// Creates an icon from its ligature [name], such as `home` or `arrow_back`.
  MaterialIcon(
    String name, {
    Object? key,
    double size = defaultSize,
    BoxColor? color,
    MaterialPalette palette = MaterialPalette.light,
    String fontFamily = defaultFontFamily,
    String? label,
  }) : this._(
         glyph: name,
         key: key,
         size: size,
         color: color ?? palette.onSurfaceVariant,
         fontFamily: fontFamily,
         label: label,
       );

  /// Creates an icon from a Unicode [codePoint] of the icon font.
  MaterialIcon.codePoint(
    int codePoint, {
    Object? key,
    double size = defaultSize,
    BoxColor? color,
    MaterialPalette palette = MaterialPalette.light,
    String fontFamily = defaultFontFamily,
    String? label,
  }) : this._(
         glyph: String.fromCharCode(codePoint),
         key: key,
         size: size,
         color: color ?? palette.onSurfaceVariant,
         fontFamily: fontFamily,
         label: label,
       );

  MaterialIcon._({
    required String glyph,
    required super.key,
    required double size,
    required BoxColor color,
    required String fontFamily,
    required String? label,
  }) : super(
         width: size,
         height: size,
         mainAlign: MainAlign.center,
         crossAlign: CrossAlign.center,
         semantics: BoxSemantics(label: label, hidden: label == null),
         textStyle: BoxTextStyle(
           fontFamily: fontFamily,
           fontSize: size,
           fontWeight: FontWeight.normal,
           lineHeight: 1,
           letterSpacing: 0,
           color: color,
         ),
         children: <UINode>[TextNode(glyph, maxLines: 1)],
       );

  /// The size Material draws an icon at: 24 logical pixels.
  static const double defaultSize = 24;

  /// The family the icon font is declared under.
  static const String defaultFontFamily = 'Material Symbols Outlined';
}
