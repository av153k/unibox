import '../enums.dart';
import 'box_color.dart';

/// An immutable bundle of typography tokens.
///
/// Typography is the only axis Unibox inherits: a box passes its text style down
/// to its descendants, exactly like CSS font properties and Flutter's
/// `DefaultTextStyle`. Layout, spacing and alignment are never inherited, so a
/// text style can never move a box, only restyle the text inside it.
///
/// Every field is optional and `null` means "inherit". [merge] therefore keeps
/// the value of the base style whenever the overlay leaves a token unset, which
/// is what makes a shared style specialisable per box.
///
/// ```dart
/// const body = BoxTextStyle(fontSize: 16, color: BoxColor.black);
/// const muted = BoxTextStyle(color: BoxColor.grey);
///
/// final caption = body.merge(muted);
/// ```
final class BoxTextStyle {
  /// Creates a text style. Unspecified tokens stay `null`.
  const BoxTextStyle({
    this.fontSize,
    this.fontWeight,
    this.color,
    this.lineHeight,
    this.fontFamily,
    this.letterSpacing,
  });

  /// The font size in logical pixels, `px` on the web.
  final double? fontSize;

  /// The weight of the font.
  final FontWeight? fontWeight;

  /// The color of the text.
  final BoxColor? color;

  /// The line height as a multiple of [fontSize].
  ///
  /// The unitless form is the only one CSS and Flutter agree on: `line-height:
  /// 1.5` and `TextStyle(height: 1.5)` both scale with the font size.
  final double? lineHeight;

  /// The font family name, resolved by the host application.
  ///
  /// Flutter falls back to the platform font when the family is unavailable,
  /// CSS does the same, so an unknown family never breaks a layout.
  final String? fontFamily;

  /// Extra space between characters in logical pixels.
  final double? letterSpacing;

  /// Whether no token is set.
  bool get isEmpty => this == const BoxTextStyle();

  /// Creates a copy of this style with the given tokens replaced.
  ///
  /// Passing `null` keeps the current value; use a fresh [BoxTextStyle] to clear
  /// tokens.
  BoxTextStyle copyWith({
    double? fontSize,
    FontWeight? fontWeight,
    BoxColor? color,
    double? lineHeight,
    String? fontFamily,
    double? letterSpacing,
  }) {
    return BoxTextStyle(
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      color: color ?? this.color,
      lineHeight: lineHeight ?? this.lineHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }

  /// Overlays [other] on top of this style.
  ///
  /// Tokens that are `null` in [other] keep the value from this style, all
  /// other tokens take precedence:
  ///
  /// ```dart
  /// final label = body.merge(const BoxTextStyle(fontWeight: FontWeight.bold));
  /// ```
  BoxTextStyle merge(BoxTextStyle? other) {
    if (other == null) {
      return this;
    }
    return BoxTextStyle(
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      color: other.color ?? color,
      lineHeight: other.lineHeight ?? lineHeight,
      fontFamily: other.fontFamily ?? fontFamily,
      letterSpacing: other.letterSpacing ?? letterSpacing,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BoxTextStyle &&
      other.fontSize == fontSize &&
      other.fontWeight == fontWeight &&
      other.color == color &&
      other.lineHeight == lineHeight &&
      other.fontFamily == fontFamily &&
      other.letterSpacing == letterSpacing;

  @override
  int get hashCode => Object.hash(
    fontSize,
    fontWeight,
    color,
    lineHeight,
    fontFamily,
    letterSpacing,
  );

  @override
  String toString() {
    final tokens = <String>[
      if (fontSize != null) 'fontSize: $fontSize',
      if (fontWeight != null) 'fontWeight: $fontWeight',
      if (color != null) 'color: $color',
      if (lineHeight != null) 'lineHeight: $lineHeight',
      if (fontFamily != null) 'fontFamily: $fontFamily',
      if (letterSpacing != null) 'letterSpacing: $letterSpacing',
    ];
    return 'BoxTextStyle(${tokens.join(', ')})';
  }
}
