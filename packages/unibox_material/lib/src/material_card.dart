import 'package:unibox_core/unibox_core.dart';

import 'material_palette.dart';
import 'material_typography.dart';

/// A Material 3 card: a surface with the padding, shape, elevation and body
/// typography Material gives a card, drawn as a [Box].
///
/// ```dart
/// const MaterialCard(
///   children: <UINode>[
///     TextNode('Order summary', style: MaterialTypography.titleMedium),
///     TextNode('Two nights, one room.'),
///   ],
/// );
/// ```
///
/// It adds no renderer work: it *is* a box, so both targets draw it with the
/// renderer they already have, and every token it sets is one the conformance
/// table already pins. What the class buys is the combination — a column with 16
/// logical pixels of padding, a 12 pixel radius, a level one drop shadow, a white
/// surface and `bodyMedium` for the texts inside — and a name that says a card.
/// A node that extends [Box] renders as that box on both targets, which the
/// renderer suites pin.
///
/// **What it is not.** It is not a colour scheme: Material picks a card's surface
/// from `surfaceContainerLow`, so the default is the baseline light value written
/// out, and a themed application passes the roles it wants —
/// `color: palette.surfaceContainerLow`, `border: BoxBorder(color:
/// palette.outlineVariant)` — from a `MaterialPalette`.
///
/// The three official variants are named constructors that take a
/// [MaterialPalette]: [MaterialCard.elevated] (`surfaceContainerLow` and the level
/// one shadow), [MaterialCard.filled] (`surfaceContainerHighest`) and
/// [MaterialCard.outlined] (`surface` and a 1 pixel `outlineVariant` border). It is
/// not a ripple: a press is [stateStyles], the same as on any other
/// control.
///
/// **The escape hatch is a [Box].** The card states its surface, the layout of
/// its content and its interaction; anything else — a style bag, opacity, a
/// transform, a size bound — is a plain box around it, and the `Box` you would
/// have written is the one this class builds.
final class MaterialCard extends Box {
  /// Creates a card, with the tokens Material gives one.
  ///
  /// `padding`, `color`, `borderRadius`, `shadow`, `border` and `textStyle` are
  /// the card's own defaults; every one is a parameter so an application can
  /// theme them without giving up the card.
  const MaterialCard({
    super.key,
    super.children,
    super.direction,
    super.mainAlign,
    super.crossAlign,
    super.gap,
    super.flex,
    super.overflow,
    super.width,
    super.height,
    super.margin,
    super.transition,
    super.hoverStyle,
    super.stateStyles,
    super.enabled,
    super.semantics,
    super.onTap,
    super.onLongPress,
    super.onHover,
    super.shadow = elevatedShadow,
    super.border,
    BoxSpacing padding = const BoxSpacing.all(16),
    BoxColor color = _elevatedSurface,
    double borderRadius = 12,
    BoxTextStyle textStyle = MaterialTypography.bodyMedium,
  }) : super(
         padding: padding,
         backgroundColor: color,
         borderRadius: borderRadius,
         textStyle: textStyle,
       );

  /// A filled card: `surfaceContainerHighest`, no shadow, 12 pixel radius.
  MaterialCard.filled({
    Object? key,
    List<UINode> children = const <UINode>[],
    MaterialPalette palette = MaterialPalette.light,
    BoxSpacing padding = const BoxSpacing.all(16),
    TapCallback? onTap,
    double? width,
    double? height,
    BoxSpacing? margin,
    Axis? direction,
    double? gap,
  }) : this(
         key: key,
         children: children,
         color: palette.surfaceContainerHighest,
         shadow: null,
         padding: padding,
         onTap: onTap,
         width: width,
         height: height,
         margin: margin,
         direction: direction,
         gap: gap,
         textStyle: _bodyOn(palette),
       );

  /// An outlined card: `surface` with a 1 pixel `outlineVariant` border, no
  /// shadow, 12 pixel radius.
  MaterialCard.outlined({
    Object? key,
    List<UINode> children = const <UINode>[],
    MaterialPalette palette = MaterialPalette.light,
    BoxSpacing padding = const BoxSpacing.all(16),
    TapCallback? onTap,
    double? width,
    double? height,
    BoxSpacing? margin,
    Axis? direction,
    double? gap,
  }) : this(
         key: key,
         children: children,
         color: palette.surface,
         shadow: null,
         border: BoxBorder(color: palette.outlineVariant),
         padding: padding,
         onTap: onTap,
         width: width,
         height: height,
         margin: margin,
         direction: direction,
         gap: gap,
         textStyle: _bodyOn(palette),
       );

  /// An elevated card in [palette]: `surfaceContainerLow` with the level one
  /// shadow, the look the default constructor states for the light scheme.
  MaterialCard.elevated({
    Object? key,
    List<UINode> children = const <UINode>[],
    MaterialPalette palette = MaterialPalette.light,
    BoxSpacing padding = const BoxSpacing.all(16),
    TapCallback? onTap,
    double? width,
    double? height,
    BoxSpacing? margin,
    Axis? direction,
    double? gap,
  }) : this(
         key: key,
         children: children,
         color: palette.surfaceContainerLow,
         padding: padding,
         onTap: onTap,
         width: width,
         height: height,
         margin: margin,
         direction: direction,
         gap: gap,
         textStyle: _bodyOn(palette),
       );

  static BoxTextStyle _bodyOn(MaterialPalette palette) => MaterialTypography
      .bodyMedium
      .merge(BoxTextStyle(color: palette.onSurface));

  /// `surfaceContainerLow` of the baseline light scheme: the elevated surface.
  ///
  /// It is a literal because a default parameter has to be a constant expression,
  /// and a field of a const object is not one. The test beside the card pins it to
  /// the palette role it names, so the two cannot drift apart.
  static const BoxColor _elevatedSurface = BoxColor(0xFFF7F2FA);

  /// The drop shadow of elevation level one, the level Material gives a resting
  /// card.
  ///
  /// Material states that level as two layers (`0 1px 2px` at 30% and `0 1px 3px
  /// 1px` at 15%); a [BoxShadow] is one shadow, so this is the second layer
  /// alone, the one that reads as a soft lift. How a shadow is blurred is outside
  /// the parity contract — a browser and Skia rasterise it differently — so the
  /// value states the shape of the shadow rather than a pixel promise.
  static const BoxShadow elevatedShadow = BoxShadow(
    color: BoxColor.rgba(0, 0, 0, 0x26),
    offsetY: 1,
    blurRadius: 3,
  );
}
