import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_conformance/unibox_conformance.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'harness.dart';

/// The presentation this renderer gave the root box rendered by [pumpNode].
///
/// The facts are read from the CSS the renderer emitted, never from the node
/// tree: every box is a flex container, so the first `div` of the page is the box
/// under test. The contract cases are resting boxes, which the renderer writes as
/// inline styles; a case that styled one of its states would move its
/// declarations into a scoped class rule and fail here, which is the direction a
/// token that stopped being rendered should fail in.
///
/// The Flutter suite reads the same facts out of the widget tree it built, and
/// both compare them with the table in `unibox_conformance`.
BoxAppearance appearanceOf() {
  final Map<String, String> styles = stylesOf(find.tag('div').first);
  final String? border = styles['border'];
  final _Border? parsed = border == null ? null : _borderOf(border);

  return BoxAppearance(
    direction: _axisOf(styles['flex-direction']),
    mainAlign: _mainAlignOf(styles['justify-content']),
    crossAlign: _crossAlignOf(styles['align-items']),
    gap: _pixelsOrNull(styles['gap']),
    padding: _spacingOrNull(styles['padding']),
    margin: _spacingOrNull(styles['margin']),
    width: _dimensionOrNull(styles['width']),
    height: _dimensionOrNull(styles['height']),
    backgroundColor: _colorOrNull(styles['background-color']),
    borderRadius: _pixelsOrNull(styles['border-radius']),
    borderWidth: parsed?.width,
    borderColor: parsed?.color,
  );
}

/// A CSS border, split into the width and the colour it draws.
final class _Border {
  /// Creates a border of [width] logical pixels in [color].
  const _Border({required this.width, required this.color});

  /// The width of the line.
  final double width;

  /// The colour of the line.
  final core.BoxColor color;
}

/// The axis a `flex-direction` names.
///
/// The renderer always writes the direction, so an unknown value is a failure to
/// read the output rather than a box that fell back to a column.
core.Axis _axisOf(String? value) {
  return switch (value) {
    'row' => core.Axis.horizontal,
    'column' => core.Axis.vertical,
    _ => throw FormatException('Not a flex direction: $value'),
  };
}

/// The main axis alignment a `justify-content` names.
///
/// CSS accepts `start` and `flex-start` for the same alignment, and Jaspr writes
/// the former.
core.MainAlign _mainAlignOf(String? value) {
  return switch (value) {
    'start' || 'flex-start' => core.MainAlign.start,
    'center' => core.MainAlign.center,
    'end' || 'flex-end' => core.MainAlign.end,
    'space-between' => core.MainAlign.spaceBetween,
    'space-around' => core.MainAlign.spaceAround,
    'space-evenly' => core.MainAlign.spaceEvenly,
    _ => throw FormatException('Not a justify-content: $value'),
  };
}

/// The cross axis alignment an `align-items` names.
core.CrossAlign _crossAlignOf(String? value) {
  return switch (value) {
    'start' || 'flex-start' => core.CrossAlign.start,
    'center' => core.CrossAlign.center,
    'end' || 'flex-end' => core.CrossAlign.end,
    'stretch' => core.CrossAlign.stretch,
    _ => throw FormatException('Not an align-items: $value'),
  };
}

/// The number of pixels in [value], which CSS may write with a unit.
double _pixels(String value) {
  return double.parse(value.replaceAll('px', '').trim());
}

/// The pixels [value] names, or `null` when there is no value.
double? _pixelsOrNull(String? value) => value == null ? null : _pixels(value);

/// The size [value] names, [double.infinity] for a percentage.
double? _dimensionOrNull(String? value) {
  if (value == null) {
    return null;
  }
  return value.endsWith('%') ? double.infinity : _pixels(value);
}

/// The spacing a `padding` or `margin` shorthand names.
core.BoxSpacing? _spacingOrNull(String? value) {
  if (value == null) {
    return null;
  }

  final List<double> sides = <double>[
    for (final String side in value.split(' ')) _pixels(side),
  ];

  return switch (sides) {
    <double>[final double all] => core.BoxSpacing.all(all),
    <double>[final double vertical, final double horizontal] =>
      core.BoxSpacing.symmetric(vertical: vertical, horizontal: horizontal),
    <double>[final double top, final double horizontal, final double bottom] =>
      core.BoxSpacing(
        top: top,
        right: horizontal,
        bottom: bottom,
        left: horizontal,
      ),
    <double>[
      final double top,
      final double right,
      final double bottom,
      final double left,
    ] =>
      core.BoxSpacing(top: top, right: right, bottom: bottom, left: left),
    _ => throw FormatException('Not a spacing: $value'),
  };
}

/// The colour [value] names, or `null` when there is no value.
core.BoxColor? _colorOrNull(String? value) =>
    value == null ? null : _color(value);

/// The colour a CSS colour value names.
core.BoxColor _color(String value) {
  if (value.startsWith('#')) {
    final String hex = value.substring(1).trim();
    final int channels = int.parse(hex, radix: 16);
    return hex.length == 6
        ? core.BoxColor(channels | 0xFF000000)
        : core.BoxColor(channels);
  }

  final RegExpMatch match = _functionPattern.firstMatch(value)!;
  final List<String> channels = match
      .group(1)!
      .split(',')
      .map((String channel) => channel.trim())
      .toList();

  return core.BoxColor.rgba(
    int.parse(channels[0]),
    int.parse(channels[1]),
    int.parse(channels[2]),
    channels.length > 3 ? (double.parse(channels[3]) * 0xFF).round() : 0xFF,
  );
}

/// The arguments of an `rgb(...)` or `rgba(...)` value.
final RegExp _functionPattern = RegExp(r'rgba?\(([^)]*)\)');

/// The border a `border` shorthand names.
_Border _borderOf(String value) {
  final RegExpMatch? line = _linePattern.firstMatch(value);
  final RegExpMatch? color = _colorPattern.firstMatch(value);

  if (line == null || color == null) {
    throw FormatException('Not a border: $value');
  }

  return _Border(
    width: double.parse(line.group(1)!),
    color: _color(color.group(0)!),
  );
}

/// The width of a border line in a `border` shorthand.
final RegExp _linePattern = RegExp(r'([\d.]+)px');

/// A colour inside a `border` shorthand, which may be a hex value or a function.
final RegExp _colorPattern = RegExp(r'#[0-9a-fA-F]{3,8}|rgba?\([^)]*\)');
