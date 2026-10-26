import '../callbacks.dart';
import '../enums.dart';
import '../tokens/box_border.dart';
import '../tokens/box_color.dart';
import '../tokens/box_shadow.dart';
import '../tokens/box_spacing.dart';
import '../tokens/box_style.dart';
import '../tokens/box_text_style.dart';
import 'ui_node.dart';

/// A flex container and the primary building block of Unibox.
///
/// A box lays out its [children] along [direction] (a `Row`/`Column` in
/// Flutter, a flex container in CSS) and paints its background, border and
/// shadow behind them.
///
/// Styling can be expressed in two ways:
/// * flat parameters (`gap`, `padding`, `backgroundColor`, ...), which are the
///   quickest to write, and
/// * a reusable [style] (plus [hoverStyle] for the hovered state).
///
/// Flat parameters always take precedence over the matching token in [style].
/// The resolved tokens are available through [computedStyle] and
/// [computedHoverStyle].
///
/// ```dart
/// const card = Box(
///   direction: Axis.vertical,
///   gap: 8,
///   padding: BoxSpacing.all(16),
///   style: BoxStyle(backgroundColor: BoxColor.white),
///   children: [TextNode('Hello')],
/// );
/// ```
class Box extends UINode {
  /// Creates a box.
  const Box({
    super.key,
    this.children = const <UINode>[],
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
    this.style,
    this.hoverStyle,
    this.stateStyles,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.onHover,
  });

  /// The child nodes laid out by this box.
  @override
  final List<UINode> children;

  // Layout.

  /// The direction children are laid out in.
  ///
  /// When `null` the box is not a flex container: children are stacked
  /// vertically in Flutter and flow as block content on the web.
  final Axis? direction;

  /// Distribution of children along the main axis.
  final MainAlign? mainAlign;

  /// Alignment of children along the cross axis.
  final CrossAlign? crossAlign;

  /// Space between children in logical pixels.
  final double? gap;

  /// How much of the remaining space this box should take up.
  final int? flex;

  /// How content exceeding the box bounds is treated.
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

  /// The background color painted behind the children.
  final BoxColor? backgroundColor;

  /// The corner radius in logical pixels.
  final double? borderRadius;

  /// The border painted around the box.
  final BoxBorder? border;

  /// The drop shadow painted behind the box.
  final BoxShadow? shadow;

  // Typography.

  /// The typography inherited by the children of this box.
  ///
  /// Text nodes inside the box take every token they do not set themselves from
  /// here, which mirrors CSS font inheritance and Flutter's
  /// `DefaultTextStyle`. It never affects layout.
  final BoxTextStyle? textStyle;

  // Style tokens.

  /// A reusable bundle of tokens, overridden by the flat parameters above.
  final BoxStyle? style;

  /// Tokens applied while the box is hovered, overriding the base style.
  ///
  /// Sugar for `stateStyles: {BoxState.hover: hoverStyle}`. An entry in
  /// [stateStyles] wins over this one.
  final BoxStyle? hoverStyle;

  /// Tokens applied while the box is in a given state.
  ///
  /// Every state overlays the resting style, so a state only has to name the
  /// tokens that change. [BoxState.disabled] wins over all other states, because
  /// a disabled box cannot be hovered, focused or pressed in the first place.
  final Map<BoxState, BoxStyle>? stateStyles;

  /// Whether the box reacts to input.
  ///
  /// A disabled box drops every callback and is reported as disabled to assistive
  /// technologies, but keeps its layout and still renders its
  /// [BoxState.disabled] style. Disabling a box therefore never moves anything.
  final bool enabled;

  // Actions.

  /// Called when the box is tapped.
  final TapCallback? onTap;

  /// Called when the box is long pressed.
  final LongPressCallback? onLongPress;

  /// Called when the pointer enters or leaves the box.
  final HoverCallback? onHover;

  /// The flat parameters of this box as a style overlay.
  BoxStyle get _flatStyle => BoxStyle(
    direction: direction,
    mainAlign: mainAlign,
    crossAlign: crossAlign,
    gap: gap,
    flex: flex,
    overflow: overflow,
    width: width,
    height: height,
    minWidth: minWidth,
    maxWidth: maxWidth,
    minHeight: minHeight,
    maxHeight: maxHeight,
    padding: padding,
    margin: margin,
    backgroundColor: backgroundColor,
    borderRadius: borderRadius,
    border: border,
    shadow: shadow,
    textStyle: textStyle,
  );

  /// The resolved style of this box in its resting state.
  ///
  /// [style] provides the defaults, every flat parameter that is not `null`
  /// overrides the matching token.
  BoxStyle get computedStyle => (style ?? const BoxStyle()).merge(_flatStyle);

  /// The tokens that apply in [state], or `null` when the state adds nothing.
  BoxStyle? stateStyle(BoxState state) {
    final BoxStyle? fromMap = stateStyles?[state];

    if (state == BoxState.hover && hoverStyle != null) {
      return fromMap == null ? hoverStyle : hoverStyle!.merge(fromMap);
    }

    return fromMap;
  }

  /// The resolved style of this box for [state].
  ///
  /// The resting style is the base and the tokens of the state are laid over
  /// it. [BoxState.disabled] always wins: a disabled box cannot be hovered,
  /// focused or pressed, and asking for the disabled style while the box is
  /// enabled still returns it, so both renderers can describe one state
  /// independently of who set [enabled].
  BoxStyle computedStyleFor(BoxState state) {
    final BoxStyle resting = computedStyle;

    if (!enabled || state == BoxState.disabled) {
      return resting.merge(stateStyle(BoxState.disabled));
    }

    return resting.merge(stateStyle(state));
  }

  /// The resolved style of this box while it is hovered.
  ///
  /// Equal to [computedStyle] when no hover tokens are set, otherwise the
  /// hovered tokens take precedence over the resting ones.
  BoxStyle get computedHoverStyle => computedStyleFor(BoxState.hover);

  /// The typography of this box, or an empty style when none is set.
  ///
  /// Renderers hand this to their descendants as the ambient text style.
  BoxTextStyle get computedTextStyle =>
      computedStyle.textStyle ?? const BoxTextStyle();

  /// Whether this box defines a distinct hovered appearance.
  bool get hasHoverStyle => stateStyle(BoxState.hover) != null;

  /// Whether this box has an interaction handler it can run.
  ///
  /// A disabled box reports `false` even when it has callbacks, so renderers
  /// serve no pointer cursor, no hover and no press for it.
  bool get isInteractive => enabled && (onTap != null || onLongPress != null);
}
