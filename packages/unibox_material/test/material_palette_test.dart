import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

void main() {
  group('MaterialPalette', () {
    test('states a Material 3 baseline light scheme', () {
      const MaterialPalette palette = MaterialPalette.light;

      expect(palette.primary, const BoxColor(0xFF6750A4));
      expect(palette.onPrimary, BoxColors.white);
      expect(palette.onSurface, const BoxColor(0xFF1D1B20));
      expect(palette.onSurfaceVariant, const BoxColor(0xFF49454F));
      expect(palette.surfaceContainerLowest, BoxColors.white);
      expect(palette.outlineVariant, const BoxColor(0xFFCAC4D0));
      expect(palette.error, const BoxColor(0xFFB3261E));
    });

    test('states a Material 3 baseline dark scheme', () {
      const MaterialPalette palette = MaterialPalette.dark;

      expect(palette.primary, const BoxColor(0xFFD0BCFF));
      expect(palette.onPrimary, const BoxColor(0xFF381E72));
      expect(palette.onSurface, const BoxColor(0xFFE6E0E9));
      expect(palette.surface, const BoxColor(0xFF141218));
      // The two schemes are not the same palette with a different name.
      expect(palette.onSurface, isNot(MaterialPalette.light.onSurface));
      expect(palette.surface, isNot(MaterialPalette.light.surface));
    });

    test('draws no text role as its own surface', () {
      // A role that names text or icons must be readable on the role it pairs
      // with, so it is never the same colour.
      for (final MaterialPalette palette in <MaterialPalette>[
        MaterialPalette.light,
        MaterialPalette.dark,
      ]) {
        expect(palette.onPrimary, isNot(palette.primary));
        expect(palette.onSurface, isNot(palette.surface));
        expect(palette.onError, isNot(palette.error));
        expect(palette.onPrimaryContainer, isNot(palette.primaryContainer));
      }
    });

    test('paints the state layers at the opacities Material states', () {
      const MaterialPalette palette = MaterialPalette.light;

      expect(palette.hoverLayer.opacity, closeTo(0.08, 0.005));
      expect(palette.pressedLayer.opacity, closeTo(0.12, 0.005));
      expect(palette.draggedLayer.opacity, closeTo(0.16, 0.005));

      // The layer is the on-surface colour, so it reads over any surface tone.
      expect(palette.hoverLayer.red, palette.onSurface.red);
      expect(palette.hoverLayer.blue, palette.onSurface.blue);
      // A dark scheme layers its own light on-surface colour.
      expect(
        MaterialPalette.dark.hoverLayer.red,
        MaterialPalette.dark.onSurface.red,
      );
    });

    test('leaves the components to take the values it holds', () {
      const MaterialPalette palette = MaterialPalette.light;

      final MaterialCard card = MaterialCard(
        color: palette.surfaceContainerLow,
        border: BoxBorder(color: palette.outlineVariant),
      );
      final MaterialListTile tile = MaterialListTile(
        title: const TextNode('Ada Lovelace'),
        color: palette.surfaceContainerLowest,
        subtitleStyle: MaterialTypography.bodyMedium.merge(
          BoxTextStyle(color: palette.onSurfaceVariant),
        ),
      );

      expect(card.backgroundColor, palette.surfaceContainerLow);
      expect(tile.backgroundColor, palette.surfaceContainerLowest);
      expect(
        (tile.children.first as Box).textStyle,
        MaterialTypography.bodyLarge,
      );
    });
  });
}
