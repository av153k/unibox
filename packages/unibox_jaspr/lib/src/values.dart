import 'package:jaspr/dom.dart';
import 'package:unibox_core/unibox_core.dart' as core;

/// Converts a Unibox [core.BoxColor] to a CSS [Color].
///
/// Opaque colors become a `#rrggbb` value, translucent ones an `rgba(...)`
/// function whose alpha is rounded to three decimals, which is more precise than
/// the eight bit channel it originates from.
Color toCssColor(core.BoxColor color) {
  if (color.isOpaque) {
    return Color.value(color.value & 0xFFFFFF);
  }
  return Color.rgba(
    color.red,
    color.green,
    color.blue,
    double.parse(color.opacity.toStringAsFixed(3)),
  );
}

/// Converts a Unibox dimension to a CSS [Unit].
///
/// `null` remains `null` so callers can omit the property entirely,
/// `double.infinity` expands to the available space (`100%`) and every other
/// value is expressed in logical pixels.
Unit? toCssUnit(double? value) {
  if (value == null) {
    return null;
  }
  if (value.isInfinite) {
    return const Unit.percent(100);
  }
  return Unit.pixels(value);
}

/// Converts a Unibox [core.BoxSpacing] to CSS [Spacing].
///
/// A uniform spacing collapses into the one value shorthand (`8px`), anything
/// else into the four value shorthand (`8px 12px 16px 4px`).
Spacing toCssSpacing(core.BoxSpacing spacing) {
  if (spacing.left == spacing.top &&
      spacing.top == spacing.right &&
      spacing.right == spacing.bottom) {
    return Spacing.all(Unit.pixels(spacing.left));
  }
  return Spacing.fromLTRB(
    Unit.pixels(spacing.left),
    Unit.pixels(spacing.top),
    Unit.pixels(spacing.right),
    Unit.pixels(spacing.bottom),
  );
}

/// Converts a Unibox [core.Axis] to a [FlexDirection].
FlexDirection toCssFlexDirection(core.Axis axis) {
  return switch (axis) {
    core.Axis.horizontal => FlexDirection.row,
    core.Axis.vertical => FlexDirection.column,
  };
}

/// Converts a Unibox [core.MainAlign] to [JustifyContent].
JustifyContent toCssJustifyContent(core.MainAlign align) {
  return switch (align) {
    core.MainAlign.start => JustifyContent.start,
    core.MainAlign.center => JustifyContent.center,
    core.MainAlign.end => JustifyContent.end,
    core.MainAlign.spaceBetween => JustifyContent.spaceBetween,
    core.MainAlign.spaceAround => JustifyContent.spaceAround,
    core.MainAlign.spaceEvenly => JustifyContent.spaceEvenly,
  };
}

/// Converts a Unibox [core.CrossAlign] to [AlignItems].
AlignItems toCssAlignItems(core.CrossAlign align) {
  return switch (align) {
    core.CrossAlign.start => AlignItems.start,
    core.CrossAlign.center => AlignItems.center,
    core.CrossAlign.end => AlignItems.end,
    core.CrossAlign.stretch => AlignItems.stretch,
  };
}

/// Converts a Unibox [core.Overflow] to CSS [Overflow].
///
/// A scrollable box maps to `overflow: auto` so that scrollbars only appear
/// when the content actually overflows, which is what a Flutter
/// `SingleChildScrollView` does as well.
Overflow toCssOverflow(core.Overflow overflow) {
  return switch (overflow) {
    core.Overflow.visible => Overflow.visible,
    core.Overflow.hidden => Overflow.hidden,
    core.Overflow.scroll => Overflow.auto,
  };
}

/// Converts a Unibox [core.BoxBorder] to a CSS [Border].
///
/// Returns `null` for missing or invisible borders so that no `border` property
/// is emitted at all.
Border? toCssBorder(core.BoxBorder? border) {
  if (border == null || !border.isVisible) {
    return null;
  }
  return Border.all(
    color: toCssColor(border.color),
    width: Unit.pixels(border.width),
  );
}

/// Converts a Unibox [core.BoxShadow] to a CSS [BoxShadow].
BoxShadow toCssBoxShadow(core.BoxShadow shadow) {
  return BoxShadow(
    offsetX: Unit.pixels(shadow.offsetX),
    offsetY: Unit.pixels(shadow.offsetY),
    blur: Unit.pixels(shadow.blurRadius),
    spread: Unit.pixels(shadow.spreadRadius),
    color: toCssColor(shadow.color),
  );
}

/// Builds the CSS of a box from its resolved [core.BoxStyle].
///
/// Unset token values are omitted so that browser defaults (and inherited
/// typography) apply, mirroring how the Flutter renderer leaves unset
/// properties to `DefaultTextStyle`.
///
/// [interactive] adds a pointer cursor for boxes that react to input.
Styles toBoxStyles(core.BoxStyle style, {bool interactive = false}) {
  final core.Axis? direction = style.direction;
  final core.BoxBorder? border = style.border;
  final core.BoxShadow? shadow = style.shadow;
  final core.BoxSpacing? padding = style.padding;
  final core.BoxSpacing? margin = style.margin;
  final core.BoxColor? backgroundColor = style.backgroundColor;
  final core.Overflow? overflow = style.overflow;
  final double? gap = style.gap;
  final double? borderRadius = style.borderRadius;
  final int? flex = style.flex;

  return Styles(
    boxSizing: BoxSizing.borderBox,
    display: direction == null ? null : Display.flex,
    flexDirection: direction == null ? null : toCssFlexDirection(direction),
    justifyContent: direction == null
        ? null
        : toCssJustifyContent(style.mainAlign ?? core.MainAlign.start),
    alignItems: direction == null
        ? null
        : toCssAlignItems(style.crossAlign ?? core.CrossAlign.start),
    gap: direction == null || gap == null ? null : Gap.all(Unit.pixels(gap)),
    flex: flex == null
        ? null
        : Flex(grow: flex.toDouble(), shrink: 1, basis: Unit.zero),
    width: toCssUnit(style.width),
    height: toCssUnit(style.height),
    minWidth: toCssUnit(style.minWidth),
    minHeight: toCssUnit(style.minHeight),
    maxWidth: toCssUnit(style.maxWidth),
    maxHeight: toCssUnit(style.maxHeight),
    padding: padding == null ? null : toCssSpacing(padding),
    margin: margin == null ? null : toCssSpacing(margin),
    backgroundColor: backgroundColor == null ? null : toCssColor(backgroundColor),
    radius: borderRadius == null
        ? null
        : BorderRadius.circular(Unit.pixels(borderRadius)),
    border: toCssBorder(border),
    shadow: shadow == null ? null : toCssBoxShadow(shadow),
    overflow: overflow == null ? null : toCssOverflow(overflow),
    cursor: interactive ? Cursor.pointer : null,
  );
}
