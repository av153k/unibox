import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

void main() {
  group('MaterialProgressIndicator', () {
    test('is a 48 pixel primary ring that turns until it has a value', () {
      final indicator = MaterialProgressIndicator();

      expect(indicator, isA<ProgressNode>());
      expect(indicator.isIndeterminate, isTrue);
      expect(indicator.size, 48);
      expect(indicator.strokeWidth, 4);
      expect(indicator.color, MaterialPalette.light.primary);
      expect(indicator.trackColor, BoxColor.transparent);
    });

    test('is determinate with a value and can draw its track', () {
      final indicator = MaterialProgressIndicator(
        value: 0.4,
        palette: MaterialPalette.dark,
        showTrack: true,
      );

      expect(indicator.value, 0.4);
      expect(indicator.color, MaterialPalette.dark.primary);
      expect(
        indicator.trackColor,
        MaterialPalette.dark.surfaceContainerHighest,
      );
    });
  });
}
