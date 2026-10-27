import 'package:unibox_core/unibox_core.dart' as core;

/// What one side of a difference did with a token: the record's `actual` field is
/// the presentation that was read back, `expected` the one the case asked for.
typedef TokenDifference = ({Object? actual, Object? expected});

/// How a box is presented once it has been rendered.
///
/// The two renderers produce different kinds of output — a widget tree on one
/// side, HTML and CSS on the other — so the only thing that can be compared is
/// what the output *does* with a box: the axis it lays its children out on, how
/// it aligns and spaces them, how big it is and what it paints behind them.
///
/// A renderer suite reads these facts back from its own output and compares them
/// with the ones a [BoxCase] expects. Only what both targets can express exactly
/// is part of it: fonts, line breaking, shadow blur, placeholder and focus
/// colours and hit testing stay approximate on purpose, because a browser and a
/// Flutter `Text` never agree on them down to the pixel.
///
/// An absent token and a zero token describe the same presentation: both
/// renderers leave an empty padding, an empty gap and an invisible border out of
/// their output, so [differencesFrom] does not distinguish the two spellings.
final class BoxAppearance {
  /// Creates a description of the presentation of a rendered box.
  ///
  /// [direction], [mainAlign] and [crossAlign] have the same defaults the model
  /// resolves an unset token to, because both renderers state the layout of
  /// every box instead of leaving it to their own default.
  const BoxAppearance({
    this.direction = core.Axis.vertical,
    this.mainAlign = core.MainAlign.start,
    this.crossAlign = core.CrossAlign.start,
    this.gap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
  });

  /// The axis the children of the box are laid out on.
  final core.Axis direction;

  /// The alignment of the children along [direction].
  final core.MainAlign mainAlign;

  /// The alignment of the children across [direction].
  final core.CrossAlign crossAlign;

  /// The space the box keeps between two children, or `null` for none.
  final double? gap;

  /// The space the box keeps between its border and its children.
  final core.BoxSpacing? padding;

  /// The space the box keeps around its border.
  final core.BoxSpacing? margin;

  /// The width of the box in logical pixels, or `double.infinity` when it fills
  /// the space its parent gives it.
  final double? width;

  /// The height of the box in logical pixels, or `double.infinity` when it fills
  /// the space its parent gives it.
  final double? height;

  /// The colour painted behind the box, or `null` for none.
  final core.BoxColor? backgroundColor;

  /// The radius of the corners of the box, or `null` for square ones.
  final double? borderRadius;

  /// The thickness of the line drawn around the box, or `null` for no border.
  final double? borderWidth;

  /// The colour of the border line, or `null` when there is no border.
  ///
  /// The colour only counts while [borderWidth] draws a line: a border that
  /// occupies no space is not painted, on either target.
  final core.BoxColor? borderColor;

  /// Whether [borderWidth] draws a line at all.
  bool get _hasBorder => (borderWidth ?? 0) > 0;

  /// The tokens this appearance presents differently from [expected].
  ///
  /// Empty when the two describe the same presentation, which is what a renderer
  /// suite asserts. Comparing token by token is what makes a failure readable:
  /// the map names the token that drifted and shows what each side did with it.
  Map<String, TokenDifference> differencesFrom(BoxAppearance expected) {
    final Map<String, TokenDifference> differences =
        <String, TokenDifference>{};

    void compare(String token, Object? actualValue, Object? expectedValue) {
      if (actualValue != expectedValue) {
        differences[token] = (actual: actualValue, expected: expectedValue);
      }
    }

    compare('direction', direction, expected.direction);
    compare('mainAlign', mainAlign, expected.mainAlign);
    compare('crossAlign', crossAlign, expected.crossAlign);
    compare('gap', gap ?? 0, expected.gap ?? 0);
    compare(
      'padding',
      padding ?? core.BoxSpacing.zero,
      expected.padding ?? core.BoxSpacing.zero,
    );
    compare(
      'margin',
      margin ?? core.BoxSpacing.zero,
      expected.margin ?? core.BoxSpacing.zero,
    );
    compare('width', width, expected.width);
    compare('height', height, expected.height);
    compare('backgroundColor', backgroundColor, expected.backgroundColor);
    compare('borderRadius', borderRadius ?? 0, expected.borderRadius ?? 0);
    compare('borderWidth', borderWidth ?? 0, expected.borderWidth ?? 0);
    compare(
      'borderColor',
      _hasBorder ? borderColor : null,
      expected._hasBorder ? expected.borderColor : null,
    );

    return differences;
  }

  @override
  bool operator ==(Object other) =>
      other is BoxAppearance && differencesFrom(other).isEmpty;

  @override
  int get hashCode => Object.hash(
    direction,
    mainAlign,
    crossAlign,
    gap ?? 0,
    padding ?? core.BoxSpacing.zero,
    margin ?? core.BoxSpacing.zero,
    width,
    height,
    backgroundColor,
    borderRadius ?? 0,
    borderWidth ?? 0,
    _hasBorder ? borderColor : null,
  );

  @override
  String toString() {
    return 'BoxAppearance('
        'direction: $direction, '
        'mainAlign: $mainAlign, '
        'crossAlign: $crossAlign, '
        'gap: $gap, '
        'padding: $padding, '
        'margin: $margin, '
        'width: $width, '
        'height: $height, '
        'backgroundColor: $backgroundColor, '
        'borderRadius: $borderRadius, '
        'borderWidth: $borderWidth, '
        'borderColor: $borderColor'
        ')';
  }
}
