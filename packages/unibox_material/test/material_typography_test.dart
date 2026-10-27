import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

/// The Material 3 type scale as the specification states it.
///
/// A record is `(role, font size, line box height, tracking, weight)`, with both
/// lengths in logical pixels; the line box is the height the specification
/// gives a line of that role, which the tokens have to reproduce as
/// `fontSize * lineHeight`.
const List<(MaterialTypeRole, double, double, double, FontWeight)>
specification = <(MaterialTypeRole, double, double, double, FontWeight)>[
  (MaterialTypeRole.displayLarge, 57, 64, -0.25, FontWeight.normal),
  (MaterialTypeRole.displayMedium, 45, 52, 0, FontWeight.normal),
  (MaterialTypeRole.displaySmall, 36, 44, 0, FontWeight.normal),
  (MaterialTypeRole.headlineLarge, 32, 40, 0, FontWeight.normal),
  (MaterialTypeRole.headlineMedium, 28, 36, 0, FontWeight.normal),
  (MaterialTypeRole.headlineSmall, 24, 32, 0, FontWeight.normal),
  (MaterialTypeRole.titleLarge, 22, 28, 0, FontWeight.normal),
  (MaterialTypeRole.titleMedium, 16, 24, 0.15, FontWeight.medium),
  (MaterialTypeRole.titleSmall, 14, 20, 0.1, FontWeight.medium),
  (MaterialTypeRole.bodyLarge, 16, 24, 0.5, FontWeight.normal),
  (MaterialTypeRole.bodyMedium, 14, 20, 0.25, FontWeight.normal),
  (MaterialTypeRole.bodySmall, 12, 16, 0.4, FontWeight.normal),
  (MaterialTypeRole.labelLarge, 14, 20, 0.1, FontWeight.medium),
  (MaterialTypeRole.labelMedium, 12, 16, 0.5, FontWeight.medium),
  (MaterialTypeRole.labelSmall, 11, 16, 0.5, FontWeight.medium),
];

void main() {
  group('MaterialTypography', () {
    test('has a style for every role, in scale order', () {
      expect(
        MaterialTypography.styles.keys.toList(),
        MaterialTypeRole.values,
        reason: 'the table is the scale, so it lists every role once, in order',
      );
    });

    test('looks a role up in the table', () {
      for (final role in MaterialTypeRole.values) {
        expect(MaterialTypography.of(role), MaterialTypography.styles[role]);
      }
      expect(
        MaterialTypography.of(MaterialTypeRole.bodyLarge),
        MaterialTypography.bodyLarge,
      );
    });

    test('states the size, tracking and weight of the specification', () {
      for (final (role, size, _, tracking, weight) in specification) {
        final style = MaterialTypography.of(role);

        expect(style.fontSize, size, reason: '$role font size');
        expect(style.letterSpacing, tracking, reason: '$role letter spacing');
        expect(style.fontWeight, weight, reason: '$role font weight');
      }
    });

    test('draws the line box the specification asks for', () {
      for (final (role, _, lineBox, _, _) in specification) {
        final style = MaterialTypography.of(role);

        expect(style.lineHeight, isNotNull, reason: '$role line height');
        expect(
          style.fontSize! * style.lineHeight!,
          closeTo(lineBox, 1e-9),
          reason: '$role line box is $lineBox logical pixels tall',
        );
      }
    });

    test('leaves the colour and the family to the theme', () {
      for (final style in MaterialTypography.styles.values) {
        expect(style.color, isNull);
        expect(style.fontFamily, isNull);
      }
    });

    test('is a complete style, so a role resets what it does not share', () {
      const boldRed = BoxTextStyle(
        fontWeight: FontWeight.bold,
        color: BoxColor.rgb(0xB3, 0x26, 0x1E),
        letterSpacing: 4,
      );

      final heading = boldRed.merge(MaterialTypography.headlineSmall);

      expect(heading.fontWeight, FontWeight.normal);
      expect(heading.letterSpacing, 0);
      expect(heading.fontSize, 24);
      expect(heading.color, const BoxColor.rgb(0xB3, 0x26, 0x1E));
    });

    test('takes a theme colour without restating the geometry', () {
      const onSurface = BoxColor.rgb(0x1D, 0x1B, 0x20);

      final themed = MaterialTypography.bodyMedium.merge(
        const BoxTextStyle(color: onSurface),
      );

      expect(themed, MaterialTypography.bodyMedium.copyWith(color: onSurface));
      expect(themed.fontSize, 14);
      expect(themed.lineHeight, 20 / 14);
      expect(themed.letterSpacing, 0.25);
    });

    test('is accepted by a text node, whose flat tokens win', () {
      const node = TextNode(
        'Price',
        style: MaterialTypography.labelMedium,
        color: BoxColor.white,
      );

      expect(node.computedStyle.fontSize, 12);
      expect(node.computedStyle.fontWeight, FontWeight.medium);
      expect(node.computedStyle.color, BoxColor.white);
    });

    test('is inherited from a box by every text inside it', () {
      const tree = Box(
        textStyle: MaterialTypography.bodyLarge,
        children: <UINode>[
          TextNode('Inherits the body role.'),
          TextNode('A caption.', style: MaterialTypography.bodySmall),
        ],
      );

      expect(tree.textStyle, MaterialTypography.bodyLarge);
      expect(
        (tree.children.last as TextNode).computedStyle,
        MaterialTypography.bodySmall,
      );
    });

    test('descends within every family of the scale', () {
      for (final family in <List<MaterialTypeRole>>[
        MaterialTypeRole.values.sublist(0, 3),
        MaterialTypeRole.values.sublist(3, 6),
        MaterialTypeRole.values.sublist(6, 9),
        MaterialTypeRole.values.sublist(9, 12),
        MaterialTypeRole.values.sublist(12, 15),
      ]) {
        final sizes = family
            .map((role) => MaterialTypography.of(role).fontSize!)
            .toList();

        expect(
          sizes,
          orderedEquals(sizes.toList()..sort((a, b) => b.compareTo(a))),
          reason: '${family.first.name} family runs large to small',
        );
      }
    });
  });
}
