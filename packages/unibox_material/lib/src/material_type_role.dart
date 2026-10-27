/// A role in the Material Design 3 type scale.
///
/// The scale is three sizes of five kinds, from the largest text a screen shows
/// to the smallest label under a control:
///
/// | Kind | Roles |
/// | --- | --- |
/// | display | [displayLarge], [displayMedium], [displaySmall] |
/// | headline | [headlineLarge], [headlineMedium], [headlineSmall] |
/// | title | [titleLarge], [titleMedium], [titleSmall] |
/// | body | [bodyLarge], [bodyMedium], [bodySmall] |
/// | label | [labelLarge], [labelMedium], [labelSmall] |
///
/// The values are declared from the largest to the smallest, so
/// `MaterialTypeRole.values` is the scale in reading order and a picker built
/// from it needs no sorting. [MaterialTypography.of] turns a role into its
/// typography.
///
/// A role says how large a text is and how much it is emphasized, not what
/// colour it is: colour belongs to the theme, so it is inherited from the box
/// around the text (see `MaterialTypography`).
enum MaterialTypeRole {
  /// The largest text, for a hero number or a display line on a wide screen.
  displayLarge,

  /// A display line, one step down from [displayLarge].
  displayMedium,

  /// A display line, one step down from [displayMedium].
  displaySmall,

  /// The largest heading, for the title of a short page.
  headlineLarge,

  /// A heading, one step down from [headlineLarge].
  headlineMedium,

  /// The smallest heading, for a section inside a page.
  headlineSmall,

  /// The title of a card, a dialog or a list section.
  titleLarge,

  /// A title for a smaller region, the size Material gives a card's label.
  titleMedium,

  /// The smallest title, for a dense row or a leading label.
  titleSmall,

  /// The long form text of a page.
  bodyLarge,

  /// The default body text of a Material application.
  bodyMedium,

  /// Supporting text, such as a caption or a hint.
  bodySmall,

  /// The text of a button or another control.
  labelLarge,

  /// A label on a control, one step down from [labelLarge].
  labelMedium,

  /// The smallest label, for a dense control or a badge.
  labelSmall,
}
