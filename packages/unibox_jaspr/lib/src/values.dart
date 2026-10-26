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

/// Converts a Unibox [core.FontWeight] to [FontWeight].
FontWeight toCssFontWeight(core.FontWeight weight) {
  return switch (weight) {
    core.FontWeight.normal => FontWeight.w400,
    core.FontWeight.medium => FontWeight.w500,
    core.FontWeight.semiBold => FontWeight.w600,
    core.FontWeight.bold => FontWeight.w700,
  };
}

/// Converts a Unibox [core.TextAlign] to [TextAlign].
TextAlign toCssTextAlign(core.TextAlign align) {
  return switch (align) {
    core.TextAlign.left => TextAlign.left,
    core.TextAlign.center => TextAlign.center,
    core.TextAlign.right => TextAlign.right,
    core.TextAlign.justify => TextAlign.justify,
  };
}

/// Builds the CSS of a text node.
///
/// Typography tokens that are unset are omitted, so the text inherits its
/// font size, weight and color from the surrounding box, just like a Flutter
/// `Text` inherits from `DefaultTextStyle`.
Styles toTextStyles(core.TextNode node) {
  final core.BoxColor? color = node.color;
  final core.TextAlign? textAlign = node.textAlign;
  final core.FontWeight? fontWeight = node.fontWeight;
  final double? fontSize = node.fontSize;

  return Styles(
    color: color == null ? null : toCssColor(color),
    textAlign: textAlign == null ? null : toCssTextAlign(textAlign),
    fontSize: fontSize == null ? null : Unit.pixels(fontSize),
    fontWeight: fontWeight == null ? null : toCssFontWeight(fontWeight),
    raw: _truncationStyles(node.maxLines, node.overflow),
  );
}

/// Builds the CSS that truncates text after [maxLines].
///
/// Clamping to a number of lines needs the prefixed `-webkit-box` layout, which
/// the typed properties do not expose, so the declarations are written raw. A
/// positive [maxLines] clamps the block, otherwise an ellipsis truncates the
/// single line. `TextOverflow.clip` suppresses the ellipsis in both cases.
Map<String, String>? _truncationStyles(
  int? maxLines,
  core.TextOverflow? overflow,
) {
  if (maxLines != null) {
    return <String, String>{
      'display': '-webkit-box',
      '-webkit-box-orient': 'vertical',
      '-webkit-line-clamp': '$maxLines',
      'overflow': 'hidden',
      if (overflow == core.TextOverflow.clip) 'text-overflow': 'clip',
    };
  }

  if (overflow == null) {
    return null;
  }

  return <String, String>{
    'overflow': 'hidden',
    'text-overflow': overflow == core.TextOverflow.ellipsis
        ? 'ellipsis'
        : 'clip',
    if (overflow == core.TextOverflow.ellipsis) 'white-space': 'nowrap',
  };
}

/// Converts a Unibox [core.ImageFit] to the CSS `object-fit` keyword.
String toCssObjectFit(core.ImageFit fit) {
  return switch (fit) {
    core.ImageFit.cover => 'cover',
    core.ImageFit.contain => 'contain',
    core.ImageFit.fill => 'fill',
  };
}

/// Builds the CSS of an image node.
///
/// The image is rendered as a block so it behaves like the leaf box it is in
/// Flutter: no baseline gap under the picture and no line box contribution.
/// `object-fit` is written raw, since the typed properties do not expose it.
Styles toImageStyles(core.ImageNode node) {
  final core.ImageFit? fit = node.fit;
  final double? borderRadius = node.borderRadius;

  return Styles(
    display: Display.block,
    width: toCssUnit(node.width),
    height: toCssUnit(node.height),
    radius: borderRadius == null
        ? null
        : BorderRadius.circular(Unit.pixels(borderRadius)),
    raw: fit == null
        ? null
        : <String, String>{'object-fit': toCssObjectFit(fit)},
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
