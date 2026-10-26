import '../enums.dart';
import 'box_border.dart';
import 'box_color.dart';
import 'box_shadow.dart';
import 'box_spacing.dart';
import 'box_text_style.dart';

/// A reusable, immutable bundle of box tokens.
///
/// Every field is optional: `null` means "not specified". A box applies flat
/// parameters on top of a style with [merge], so flat parameters always win
/// over matching style tokens.
///
/// A [textStyle] is the one exception to "a box styles itself": typography is
/// inherited by the descendants of the box, the way CSS font properties and
/// Flutter's `DefaultTextStyle` are. Every other token only affects the box.
///
/// ```dart
/// const cardStyle = BoxStyle(
///   padding: BoxSpacing.all(16),
///   backgroundColor: BoxColor.white,
///   borderRadius: 12,
///   textStyle: BoxTextStyle(fontSize: 16),
/// );
/// ```
final class BoxStyle {
  /// Creates a style bundle. Unspecified tokens stay `null`.
  const BoxStyle({
    this.direction,
    this.mainAlign,
    this.crossAlign,
    this.gap,
    this.flex,
    this.overflow,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.shadow,
    this.textStyle,
  });

  // Layout.

  /// The layout direction of the children.
  final Axis? direction;

  /// Distribution of the children along the main axis.
  final MainAlign? mainAlign;

  /// Alignment of the children along the cross axis.
  final CrossAlign? crossAlign;

  /// Space between children in logical pixels.
  final double? gap;

  /// How much of the remaining space this box should take up.
  final int? flex;

  /// How overflowing content is treated.
  final Overflow? overflow;

  // Dimensions.

  /// The width in logical pixels, or `double.infinity` to expand.
  final double? width;

  /// The height in logical pixels, or `double.infinity` to expand.
  final double? height;

  /// The minimum width in logical pixels.
  final double? minWidth;

  /// The maximum width in logical pixels.
  final double? maxWidth;

  /// The minimum height in logical pixels.
  final double? minHeight;

  /// The maximum height in logical pixels.
  final double? maxHeight;

  // Visuals.

  /// Space reserved inside the box.
  final BoxSpacing? padding;

  /// Space reserved outside the box.
  final BoxSpacing? margin;

  /// The background color of the box.
  final BoxColor? backgroundColor;

  /// The corner radius in logical pixels.
  final double? borderRadius;

  /// The border painted around the box.
  final BoxBorder? border;

  /// The drop shadow painted behind the box.
  final BoxShadow? shadow;

  // Typography.

  /// The typography inherited by the descendants of the box.
  ///
  /// Merging two styles merges their text styles token by token, so a box can
  /// change a single font token of an inherited style.
  final BoxTextStyle? textStyle;

  /// Whether no token is set.
  bool get isEmpty => this == const BoxStyle();

  /// Creates a copy of this style with the given tokens replaced.
  ///
  /// Passing `null` keeps the current value; use a fresh [BoxStyle] to clear
  /// tokens.
  BoxStyle copyWith({
    Axis? direction,
    MainAlign? mainAlign,
    CrossAlign? crossAlign,
    double? gap,
    int? flex,
    Overflow? overflow,
    double? width,
    double? height,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    BoxSpacing? padding,
    BoxSpacing? margin,
    BoxColor? backgroundColor,
    double? borderRadius,
    BoxBorder? border,
    BoxShadow? shadow,
    BoxTextStyle? textStyle,
  }) {
    return BoxStyle(
      direction: direction ?? this.direction,
      mainAlign: mainAlign ?? this.mainAlign,
      crossAlign: crossAlign ?? this.crossAlign,
      gap: gap ?? this.gap,
      flex: flex ?? this.flex,
      overflow: overflow ?? this.overflow,
      width: width ?? this.width,
      height: height ?? this.height,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Overlays [other] on top of this style.
  ///
  /// Tokens that are `null` in [other] keep the value from this style, all
  /// other tokens take precedence. This is how flat box parameters override
  /// style tokens:
  ///
  /// ```dart
  /// final effective = style.merge(const BoxStyle(padding: BoxSpacing.all(8)));
  /// ```
  BoxStyle merge(BoxStyle? other) {
    if (other == null) {
      return this;
    }
    return BoxStyle(
      direction: other.direction ?? direction,
      mainAlign: other.mainAlign ?? mainAlign,
      crossAlign: other.crossAlign ?? crossAlign,
      gap: other.gap ?? gap,
      flex: other.flex ?? flex,
      overflow: other.overflow ?? overflow,
      width: other.width ?? width,
      height: other.height ?? height,
      minWidth: other.minWidth ?? minWidth,
      maxWidth: other.maxWidth ?? maxWidth,
      minHeight: other.minHeight ?? minHeight,
      maxHeight: other.maxHeight ?? maxHeight,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
      border: other.border ?? border,
      shadow: other.shadow ?? shadow,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BoxStyle &&
      other.direction == direction &&
      other.mainAlign == mainAlign &&
      other.crossAlign == crossAlign &&
      other.gap == gap &&
      other.flex == flex &&
      other.overflow == overflow &&
      other.width == width &&
      other.height == height &&
      other.minWidth == minWidth &&
      other.maxWidth == maxWidth &&
      other.minHeight == minHeight &&
      other.maxHeight == maxHeight &&
      other.padding == padding &&
      other.margin == margin &&
      other.backgroundColor == backgroundColor &&
      other.borderRadius == borderRadius &&
      other.border == border &&
      other.shadow == shadow &&
      other.textStyle == textStyle;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    direction,
    mainAlign,
    crossAlign,
    gap,
    flex,
    overflow,
    width,
    height,
    minWidth,
    maxWidth,
    minHeight,
    maxHeight,
    padding,
    margin,
    backgroundColor,
    borderRadius,
    border,
    shadow,
    textStyle,
  ]);

  @override
  String toString() {
    final tokens = <String>[
      if (direction != null) 'direction: $direction',
      if (mainAlign != null) 'mainAlign: $mainAlign',
      if (crossAlign != null) 'crossAlign: $crossAlign',
      if (gap != null) 'gap: $gap',
      if (flex != null) 'flex: $flex',
      if (overflow != null) 'overflow: $overflow',
      if (width != null) 'width: $width',
      if (height != null) 'height: $height',
      if (minWidth != null) 'minWidth: $minWidth',
      if (maxWidth != null) 'maxWidth: $maxWidth',
      if (minHeight != null) 'minHeight: $minHeight',
      if (maxHeight != null) 'maxHeight: $maxHeight',
      if (padding != null) 'padding: $padding',
      if (margin != null) 'margin: $margin',
      if (backgroundColor != null) 'backgroundColor: $backgroundColor',
      if (borderRadius != null) 'borderRadius: $borderRadius',
      if (border != null) 'border: $border',
      if (shadow != null) 'shadow: $shadow',
      if (textStyle != null) 'textStyle: $textStyle',
    ];
    return 'BoxStyle(${tokens.join(', ')})';
  }
}
