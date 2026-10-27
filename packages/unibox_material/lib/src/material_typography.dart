import 'package:unibox_core/unibox_core.dart';

import 'material_type_role.dart';

/// The Material Design 3 type scale, written as [BoxTextStyle] values.
///
/// The fifteen roles are Material's, with its font size, weight, letter
/// spacing and line height. They are tokens rather than a Flutter `TextTheme`,
/// so the same style reaches a browser as CSS and a Flutter app as a
/// `TextStyle`; a tree can be typeset like a Material application on both
/// targets without either renderer knowing that Material exists.
///
/// ```dart
/// const Box(
///   textStyle: MaterialTypography.bodyMedium,
///   children: <UINode>[
///     TextNode('Order summary', style: MaterialTypography.titleLarge),
///     TextNode('Two nights, one room.'),
///   ],
/// );
/// ```
///
/// **What a role states.** A role is a complete look for the text it is applied
/// to: size, weight, tracking and line height are all written down, so a
/// `titleMedium` inside a bold heading is a 500 weight title and not a bold one.
/// That is why every token is set here and why [BoxTextStyle.merge] can be used
/// to specialise a role without undoing the rest of it.
///
/// **What it leaves out.** `color` and `fontFamily` stay `null`, which means
/// "inherit": both are theme decisions rather than roles, the colour of the text
/// comes from the box above it (Material's `onSurface` and its variants), and a
/// font family is an asset the application ships. Leaving them unset is what lets
/// one scale serve a light theme, a dark theme and an app with its own font:
///
/// ```dart
/// const onSurface = BoxColor.rgb(0x1D, 0x1B, 0x20);
/// final body = MaterialTypography.bodyMedium.merge(
///   const BoxTextStyle(color: onSurface),
/// );
/// ```
///
/// **Where the numbers come from.** They are the Material 3 specification's type
/// scale, the same one Flutter ships as `Typography.englishLike2021`. The two
/// forms of a line height are the reason for the fractions: the specification
/// states a line box in pixels (64 for display large at 57 pixels), while
/// [BoxTextStyle.lineHeight] is a multiple of the font size, because that is the
/// only form CSS and Flutter both scale the same way. `64 / 57` therefore draws
/// the specification's 64 pixel line box instead of Flutter's rounded `1.12`,
/// which is 0.16 of a pixel shorter.
abstract final class MaterialTypography {
  /// The largest text of the scale, for a hero number or a display line.
  static const BoxTextStyle displayLarge = BoxTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.normal,
    lineHeight: 64 / 57,
    letterSpacing: -0.25,
  );

  /// A display line, one step down from [displayLarge].
  static const BoxTextStyle displayMedium = BoxTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.normal,
    lineHeight: 52 / 45,
    letterSpacing: 0,
  );

  /// A display line, one step down from [displayMedium].
  static const BoxTextStyle displaySmall = BoxTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.normal,
    lineHeight: 44 / 36,
    letterSpacing: 0,
  );

  /// The largest heading, for the title of a short page.
  static const BoxTextStyle headlineLarge = BoxTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.normal,
    lineHeight: 40 / 32,
    letterSpacing: 0,
  );

  /// A heading, one step down from [headlineLarge].
  static const BoxTextStyle headlineMedium = BoxTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    lineHeight: 36 / 28,
    letterSpacing: 0,
  );

  /// The smallest heading, for a section inside a page.
  static const BoxTextStyle headlineSmall = BoxTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    lineHeight: 32 / 24,
    letterSpacing: 0,
  );

  /// The title of a card, a dialog or a list section.
  static const BoxTextStyle titleLarge = BoxTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.normal,
    lineHeight: 28 / 22,
    letterSpacing: 0,
  );

  /// A title for a smaller region.
  static const BoxTextStyle titleMedium = BoxTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.medium,
    lineHeight: 24 / 16,
    letterSpacing: 0.15,
  );

  /// The smallest title, for a dense row or a leading label.
  static const BoxTextStyle titleSmall = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.medium,
    lineHeight: 20 / 14,
    letterSpacing: 0.1,
  );

  /// The long form text of a page.
  static const BoxTextStyle bodyLarge = BoxTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    lineHeight: 24 / 16,
    letterSpacing: 0.5,
  );

  /// The default body text of a Material application.
  static const BoxTextStyle bodyMedium = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    lineHeight: 20 / 14,
    letterSpacing: 0.25,
  );

  /// Supporting text, such as a caption or a hint.
  static const BoxTextStyle bodySmall = BoxTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    lineHeight: 16 / 12,
    letterSpacing: 0.4,
  );

  /// The text of a button or another control.
  static const BoxTextStyle labelLarge = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.medium,
    lineHeight: 20 / 14,
    letterSpacing: 0.1,
  );

  /// A label on a control, one step down from [labelLarge].
  static const BoxTextStyle labelMedium = BoxTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.medium,
    lineHeight: 16 / 12,
    letterSpacing: 0.5,
  );

  /// The smallest label, for a dense control or a badge.
  static const BoxTextStyle labelSmall = BoxTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.medium,
    lineHeight: 16 / 11,
    letterSpacing: 0.5,
  );

  /// The whole scale, in the order of [MaterialTypeRole.values].
  ///
  /// The constants above are the API; this table is the same values for code
  /// that walks the scale instead of naming a role — a style picker, a
  /// documentation page, or a test that holds every entry to the specification.
  static const Map<MaterialTypeRole, BoxTextStyle> styles =
      <MaterialTypeRole, BoxTextStyle>{
        MaterialTypeRole.displayLarge: displayLarge,
        MaterialTypeRole.displayMedium: displayMedium,
        MaterialTypeRole.displaySmall: displaySmall,
        MaterialTypeRole.headlineLarge: headlineLarge,
        MaterialTypeRole.headlineMedium: headlineMedium,
        MaterialTypeRole.headlineSmall: headlineSmall,
        MaterialTypeRole.titleLarge: titleLarge,
        MaterialTypeRole.titleMedium: titleMedium,
        MaterialTypeRole.titleSmall: titleSmall,
        MaterialTypeRole.bodyLarge: bodyLarge,
        MaterialTypeRole.bodyMedium: bodyMedium,
        MaterialTypeRole.bodySmall: bodySmall,
        MaterialTypeRole.labelLarge: labelLarge,
        MaterialTypeRole.labelMedium: labelMedium,
        MaterialTypeRole.labelSmall: labelSmall,
      };

  /// The typography of [role].
  ///
  /// Every role has an entry, so this never returns `null`; prefer the
  /// constants when the role is known at author time and this when it is data.
  static BoxTextStyle of(MaterialTypeRole role) => styles[role]!;
}
