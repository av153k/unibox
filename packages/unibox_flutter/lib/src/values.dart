import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

/// Converts a Unibox [core.BoxColor] to a Flutter [Color].
Color toColor(core.BoxColor color) => Color(color.value);

/// Converts a Unibox [core.BoxSpacing] to Flutter [EdgeInsets].
EdgeInsets toEdgeInsets(core.BoxSpacing spacing) => EdgeInsets.fromLTRB(
  spacing.left,
  spacing.top,
  spacing.right,
  spacing.bottom,
);

/// Converts a Unibox [core.Axis] to a Flutter [Axis].
Axis toAxis(core.Axis axis) =>
    axis == core.Axis.horizontal ? Axis.horizontal : Axis.vertical;

/// Converts a Unibox [core.MainAlign] to Flutter [MainAxisAlignment].
MainAxisAlignment toMainAxisAlignment(core.MainAlign align) {
  return switch (align) {
    core.MainAlign.start => MainAxisAlignment.start,
    core.MainAlign.center => MainAxisAlignment.center,
    core.MainAlign.end => MainAxisAlignment.end,
    core.MainAlign.spaceBetween => MainAxisAlignment.spaceBetween,
    core.MainAlign.spaceAround => MainAxisAlignment.spaceAround,
    core.MainAlign.spaceEvenly => MainAxisAlignment.spaceEvenly,
  };
}

/// Converts a Unibox [core.CrossAlign] to Flutter [CrossAxisAlignment].
CrossAxisAlignment toCrossAxisAlignment(core.CrossAlign align) {
  return switch (align) {
    core.CrossAlign.start => CrossAxisAlignment.start,
    core.CrossAlign.center => CrossAxisAlignment.center,
    core.CrossAlign.end => CrossAxisAlignment.end,
    core.CrossAlign.stretch => CrossAxisAlignment.stretch,
  };
}

/// Converts a Unibox [core.BoxShadow] to a Flutter [BoxShadow].
BoxShadow toBoxShadow(core.BoxShadow shadow) {
  return BoxShadow(
    color: toColor(shadow.color),
    offset: Offset(shadow.offsetX, shadow.offsetY),
    blurRadius: shadow.blurRadius,
    spreadRadius: shadow.spreadRadius,
  );
}

/// Builds the [BoxDecoration] painted behind a box for [style].
///
/// Returns `null` when the style paints nothing, so that no extra layer is
/// inserted in the widget tree.
BoxDecoration? toDecoration(core.BoxStyle style) {
  final core.BoxBorder? border = style.border;
  final bool hasBorder = border != null && border.isVisible;
  final core.BoxShadow? shadow = style.shadow;
  final double? borderRadius = style.borderRadius;
  final core.BoxColor? backgroundColor = style.backgroundColor;

  if (backgroundColor == null &&
      !hasBorder &&
      shadow == null &&
      borderRadius == null) {
    return null;
  }

  return BoxDecoration(
    color: backgroundColor == null ? null : toColor(backgroundColor),
    border: hasBorder
        ? Border.all(color: toColor(border.color), width: border.width)
        : null,
    borderRadius: borderRadius == null
        ? null
        : BorderRadius.circular(borderRadius),
    boxShadow: shadow == null ? null : <BoxShadow>[toBoxShadow(shadow)],
  );
}

/// Builds the [BoxConstraints] described by the min/max tokens of [style].
///
/// Returns `null` when the style sets no bounds.
BoxConstraints? toConstraints(core.BoxStyle style) {
  if (style.minWidth == null &&
      style.maxWidth == null &&
      style.minHeight == null &&
      style.maxHeight == null) {
    return null;
  }

  return BoxConstraints(
    minWidth: style.minWidth ?? 0,
    maxWidth: style.maxWidth ?? double.infinity,
    minHeight: style.minHeight ?? 0,
    maxHeight: style.maxHeight ?? double.infinity,
  );
}
