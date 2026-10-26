import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';

import 'harness.dart';

/// The boxes of the rendered tree, in document order, with the presentation the
/// web renderer emitted for each one.
///
/// Every Unibox box renders as a flex container, so the `div`s that declare
/// `display: flex` are exactly the boxes of the tree, in document order — the
/// same list the Flutter suite collects from its widget tree. A box with state
/// styles carries its resting declarations in a scoped class rule instead of an
/// inline style, so the facts are assembled the way the browser assembles them:
/// the class rule, then the rule for the state the element is in, then whatever
/// the element declares itself.
List<BoxFact> boxFactsOf() {
  final Map<String, _Scoped> rules = _styleRules();
  final List<BoxFact> facts = <BoxFact>[];

  for (final TestRenderElement element in elementsOf(find.tag('div'))) {
    final Map<String, String> styles = _stylesOf(element, rules);
    if (styles['display'] == 'flex') {
      facts.add(_factOf(styles));
    }
  }

  return facts;
}

/// The facts of one box, from the declarations that apply to it.
BoxFact _factOf(Map<String, String> styles) {
  final String? border = styles['border'];
  final _Border? parsed = border == null ? null : _borderOf(border);

  return BoxFact(
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

/// The declarations that apply to [element].
Map<String, String> _stylesOf(
  TestRenderElement element,
  Map<String, _Scoped> rules,
) {
  final String? classes = element.classes;
  final _Scoped? scoped = classes == null ? null : rules[classes];
  final bool disabled = element.attributes?['aria-disabled'] == 'true';

  return <String, String>{
    ...?scoped?.resting,
    if (disabled) ...?scoped?.disabled,
    ...?element.styles,
  };
}

/// The scoped rules the renderer emitted for a box with state styles.
final class _Scoped {
  /// Creates the rules of one class name.
  const _Scoped({required this.resting, required this.disabled});

  /// The declarations of the class itself.
  final Map<String, String> resting;

  /// The declarations of the rule that matches a disabled box.
  final Map<String, String> disabled;
}

/// Every class rule of the stylesheets in the rendered tree, by class name.
///
/// The state rules of a box are pseudo classes of its class, so only the rule of
/// the class itself and the one that matches the `aria-disabled` attribute can
/// apply to a box that is not being pointed at.
Map<String, _Scoped> _styleRules() {
  final Map<String, Map<String, String>> resting =
      <String, Map<String, String>>{};
  final Map<String, Map<String, String>> disabled =
      <String, Map<String, String>>{};

  for (final TestRenderElement element in elementsOf(find.tag('style'))) {
    final String css = element.children
        .whereType<TestRenderText>()
        .map((TestRenderText child) => child.text)
        .join();

    for (final RegExpMatch match in _rulePattern.allMatches(css)) {
      final String className = match.group(1)!;
      final String suffix = match.group(2)!.trim();
      final Map<String, String> declarations = _declarationsOf(match.group(3)!);

      if (suffix.isEmpty) {
        resting[className] = <String, String>{
          ...?resting[className],
          ...declarations,
        };
      } else if (suffix == _disabledSuffix) {
        disabled[className] = <String, String>{
          ...?disabled[className],
          ...declarations,
        };
      }
    }
  }

  return <String, _Scoped>{
    for (final String className in <String>{...resting.keys, ...disabled.keys})
      className: _Scoped(
        resting: resting[className] ?? const <String, String>{},
        disabled: disabled[className] ?? const <String, String>{},
      ),
  };
}

/// The pseudo class suffix of the rule that matches a disabled box.
const String _disabledSuffix = '[aria-disabled="true"]';

/// A `.unibox-box-<hash><suffix> { ... }` rule, with its selector suffix and its
/// declarations.
final RegExp _rulePattern = RegExp(
  r'\.(unibox-box-[0-9a-f]+)([^{]*)\{([^}]*)\}',
);

/// The declarations of a rule body in [body], by property.
Map<String, String> _declarationsOf(String body) {
  final Map<String, String> declarations = <String, String>{};

  for (final String declaration in body.split(';')) {
    final int colon = declaration.indexOf(':');
    if (colon == -1) {
      continue;
    }
    declarations[declaration.substring(0, colon).trim()] = declaration
        .substring(colon + 1)
        .trim();
  }

  return declarations;
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
core.Axis _axisOf(String? value) {
  return value == 'row' ? core.Axis.horizontal : core.Axis.vertical;
}

/// The main axis alignment a `justify-content` names.
core.MainAlign _mainAlignOf(String? value) {
  return switch (value) {
    'center' => core.MainAlign.center,
    'end' => core.MainAlign.end,
    'space-between' => core.MainAlign.spaceBetween,
    'space-around' => core.MainAlign.spaceAround,
    'space-evenly' => core.MainAlign.spaceEvenly,
    _ => core.MainAlign.start,
  };
}

/// The cross axis alignment an `align-items` names.
core.CrossAlign _crossAlignOf(String? value) {
  return switch (value) {
    'center' => core.CrossAlign.center,
    'end' => core.CrossAlign.end,
    'stretch' => core.CrossAlign.stretch,
    _ => core.CrossAlign.start,
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
