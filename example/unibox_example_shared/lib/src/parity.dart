import 'package:unibox_core/unibox_core.dart';

import 'signup_card.dart';

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

  /// How many text fields the card renders.
  static const int inputCount = 2;

  /// Where the docs link points.
  static const String docsUrl = 'https://unibox.dev';
}
