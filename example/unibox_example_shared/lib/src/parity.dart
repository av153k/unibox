import 'package:unibox_core/unibox_core.dart';

import 'signup_card.dart';

/// How one box of the example card is presented once it is rendered.
///
/// A fact describes the *applied* presentation, not the node tree: every suite
/// reads the facts out of its own rendered output — Flutter from the widgets the
/// renderer built, the web from the inline CSS it emitted — so one fixture pins
/// both targets to the same layout and the same paint. A renderer that drops a
/// token, or a card that grows a wrapper only one target knows about, fails a
/// test instead of letting the two renderings drift apart.
///
/// Only what both targets express exactly is compared. Fonts, line breaking,
/// shadows and hit testing stay approximate on purpose, because a browser and a
/// Flutter `Text` never agree on them down to the pixel.
final class BoxFact {
  /// Creates a fact about one box.
  const BoxFact({
    this.direction = Axis.vertical,
    this.mainAlign = MainAlign.start,
    this.crossAlign = CrossAlign.start,
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

  /// The axis the children of the box are laid out along.
  final Axis direction;

  /// How the children are distributed along [direction].
  final MainAlign mainAlign;

  /// How the children are aligned across [direction].
  final CrossAlign crossAlign;

  /// The space between two children, or `null` for none.
  final double? gap;

  /// The space between the border and the content, or `null` for none.
  final BoxSpacing? padding;

  /// The space around the box, or `null` for none.
  final BoxSpacing? margin;

  /// The width in logical pixels, [double.infinity] for "fill the space".
  final double? width;

  /// The height in logical pixels, [double.infinity] for "fill the space".
  final double? height;

  /// The colour painted behind the content, or `null` for none.
  final BoxColor? backgroundColor;

  /// The radius every corner is rounded by, or `null` for square corners.
  final double? borderRadius;

  /// The width of the border, or `null` for no border.
  final double? borderWidth;

  /// The colour of the border, or `null` for no border.
  final BoxColor? borderColor;

  /// Whether [other] presents the box the same way.
  ///
  /// A token that is absent and a token that is zero are the same thing: both
  /// renderers leave an empty padding, an empty gap and a transparent border out
  /// of their output entirely, so comparing the two spellings would only test
  /// which one a renderer happens to use.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is BoxFact &&
        other.direction == direction &&
        other.mainAlign == mainAlign &&
        other.crossAlign == crossAlign &&
        other.width == width &&
        other.height == height &&
        other.backgroundColor == backgroundColor &&
        (other.gap ?? 0) == (gap ?? 0) &&
        (other.borderRadius ?? 0) == (borderRadius ?? 0) &&
        (other.borderWidth ?? 0) == (borderWidth ?? 0) &&
        (other.borderColor ?? _transparent) == (borderColor ?? _transparent) &&
        (other.padding ?? BoxSpacing.zero) == (padding ?? BoxSpacing.zero) &&
        (other.margin ?? BoxSpacing.zero) == (margin ?? BoxSpacing.zero);
  }

  @override
  int get hashCode => Object.hash(
    direction,
    mainAlign,
    crossAlign,
    width,
    height,
    backgroundColor,
    gap ?? 0,
    borderRadius ?? 0,
    borderWidth ?? 0,
    borderColor ?? _transparent,
    padding ?? BoxSpacing.zero,
    margin ?? BoxSpacing.zero,
  );

  @override
  String toString() {
    final List<String> parts = <String>[
      'direction: ${direction.name}',
      'main: ${mainAlign.name}',
      'cross: ${crossAlign.name}',
      if (gap != null && gap != 0) 'gap: $gap',
      if (padding != null && !padding!.isZero) 'padding: $padding',
      if (margin != null && !margin!.isZero) 'margin: $margin',
      if (width != null) 'width: ${_size(width!)}',
      if (height != null) 'height: ${_size(height!)}',
      if (backgroundColor != null) 'background: ${_color(backgroundColor!)}',
      if (borderRadius != null && borderRadius != 0) 'radius: $borderRadius',
      if (borderWidth != null && borderWidth != 0)
        'border: $borderWidth ${borderColor == null ? '?' : _color(borderColor!)}',
    ];

    return 'BoxFact(${parts.join(', ')})';
  }
}

/// A colour that stands in for "no border".
const BoxColor _transparent = BoxColor(0x00000000);

/// A dimension the way a fact prints it.
String _size(double value) => value.isInfinite ? 'fill' : '$value';

/// A colour the way CSS writes it.
String _color(BoxColor color) {
  final String rgb = (color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  if (color.isOpaque) {
    return '#$rgb';
  }
  return '#$rgb (alpha ${(color.opacity * 100).toStringAsFixed(0)}%)';
}

/// A text the example card shows, with the typography it must resolve to.
///
/// Only the tokens that are set are checked: `null` means "inherited from
/// wherever", which both renderers leave to their platform.
final class TextFact {
  /// Creates a fact about [text].
  const TextFact({required this.text, required this.typography});

  /// The text as it appears on screen.
  final String text;

  /// The typography the text has to end up with.
  final BoxTextStyle typography;

  @override
  String toString() => 'TextFact($text, $typography)';
}

/// A box the example card describes to assistive technologies.
final class RoleFact {
  /// Creates a fact about a described box.
  const RoleFact({required this.role, required this.label, this.checked});

  /// The role the box plays.
  final BoxRole role;

  /// The accessible name of the box.
  final String label;

  /// The checked state of a checkbox or a switch.
  final bool? checked;

  @override
  String toString() => 'RoleFact($role, $label)';
}

/// The facts both renderer suites assert about the example card.
///
/// The suites render the same tree, so they have to agree on what the user sees.
/// Naming the expectations once means a change to the card that only one target
/// follows fails a test instead of drifting quietly.
abstract final class CardParity {
  /// The texts of the card with their resolved typography.
  ///
  /// The list deliberately sticks to texts whose typography is declared on an
  /// element of their own or on a plain ancestor: a text that inherits through a
  /// state style is styled by a scoped CSS rule on the web, which the fixture
  /// cannot read back from the rendered tree.
  static const List<TextFact> texts = <TextFact>[
    TextFact(
      text: 'Join Unibox',
      typography: BoxTextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: ExamplePalette.text,
      ),
    ),
    TextFact(
      text: 'One description, two renderers.',
      typography: BoxTextStyle(fontSize: 13, color: ExamplePalette.muted),
    ),
    TextFact(text: 'Release notes', typography: ExampleType.body),
    TextFact(text: 'Read the docs', typography: ExampleType.link),
  ];

  /// The boxes the card describes, with the accessible name of each.
  static const List<RoleFact> roles = <RoleFact>[
    RoleFact(role: BoxRole.button, label: 'Create account'),
    RoleFact(role: BoxRole.checkbox, label: 'Release notes', checked: false),
  ];

  /// Every box of the card in its initial state, in document order.
  ///
  /// The order is the order the tree paints in, so the fixture reads like a
  /// pre-order walk of the card:
  ///
  /// 1. the page that centres the card on the canvas,
  /// 2. the card itself,
  /// 3. the banner behind the avatar,
  /// 4. the avatar chip,
  /// 5. the heading,
  /// 6. the name field,
  /// 7. the email field,
  /// 8. the newsletter row,
  /// 9. the hand drawn checkbox,
  /// 10. the footer,
  /// 11. the submit button,
  /// 12. the row around the docs link.
  ///
  /// The state matters: an empty form renders a disabled submit button, so the
  /// facts of the button are the ones of its disabled style.
  static const List<BoxFact> boxes = <BoxFact>[
    // 1. The page: it fills the host surface and centres the card on the canvas.
    BoxFact(
      mainAlign: MainAlign.center,
      crossAlign: CrossAlign.center,
      padding: BoxSpacing.all(24),
      width: double.infinity,
      height: double.infinity,
      backgroundColor: ExamplePalette.canvas,
    ),
    // 2. The card: a fixed width column on a raised, rounded surface.
    BoxFact(
      gap: 16,
      padding: BoxSpacing.all(24),
      width: 380,
      backgroundColor: ExamplePalette.surface,
      borderRadius: 16,
      borderWidth: 1,
      borderColor: ExamplePalette.border,
    ),
    // 3. The banner: a full width strip behind the avatar.
    BoxFact(
      width: double.infinity,
      height: 88,
      backgroundColor: ExamplePalette.accent,
      borderRadius: 12,
    ),
    // 4. The avatar chip: a circle centred on the banner edge.
    BoxFact(
      direction: Axis.horizontal,
      mainAlign: MainAlign.center,
      crossAlign: CrossAlign.center,
      width: 64,
      height: 64,
      backgroundColor: ExamplePalette.surface,
      borderRadius: 32,
      borderWidth: 4,
      borderColor: ExamplePalette.accent,
    ),
    // 5. The heading: a title and a subtitle stacked with a small gap.
    BoxFact(gap: 4),
    // 6. and 7. The two fields: the box draws what the platform field does not.
    BoxFact(
      padding: BoxSpacing.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: ExamplePalette.surface,
      borderRadius: 10,
      borderWidth: 1,
      borderColor: ExamplePalette.border,
    ),
    BoxFact(
      padding: BoxSpacing.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: ExamplePalette.surface,
      borderRadius: 10,
      borderWidth: 1,
      borderColor: ExamplePalette.border,
    ),
    // 8. The newsletter row: a label centred next to the checkbox.
    BoxFact(direction: Axis.horizontal, crossAlign: CrossAlign.center, gap: 12),
    // 9. The checkbox: a small rounded square, centred while it is empty.
    BoxFact(
      direction: Axis.horizontal,
      mainAlign: MainAlign.center,
      crossAlign: CrossAlign.center,
      width: 24,
      height: 24,
      backgroundColor: ExamplePalette.surface,
      borderRadius: 6,
      borderWidth: 2,
      borderColor: ExamplePalette.border,
    ),
    // 10. The footer: the button and the link, stacked.
    BoxFact(gap: 12),
    // 11. The submit button: full width, disabled while the form is incomplete.
    BoxFact(
      direction: Axis.horizontal,
      mainAlign: MainAlign.center,
      padding: BoxSpacing.symmetric(horizontal: 18, vertical: 12),
      width: double.infinity,
      backgroundColor: ExamplePalette.border,
      borderRadius: 10,
    ),
    // 12. The row that centres the docs link.
    BoxFact(direction: Axis.horizontal, mainAlign: MainAlign.center),
  ];

  /// How many text fields the card renders.
  static const int inputCount = 2;

  /// Where the docs link points.
  static const String docsUrl = 'https://unibox.dev';
}
