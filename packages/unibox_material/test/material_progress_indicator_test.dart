import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

void main() {
  group('MaterialProgressIndicator', () {
    test(
      'is a 48 pixel ring in the primary role that turns until it has a value',
      () {
        const indicator = MaterialProgressIndicator();

        expect(indicator, isA<ProgressNode>());
        expect(indicator.isIndeterminate, isTrue);
        expect(indicator.size, 48);
        expect(indicator.strokeWidth, 4);
        expect(indicator.color, const BoxColor.role(MaterialColorRole.primary));
        expect(indicator.trackColor, BoxColor.transparent);
      },
    );

    test('is determinate with a value and can draw its track', () {
      const indicator = MaterialProgressIndicator(value: 0.4, showTrack: true);

      expect(indicator.value, 0.4);
      expect(
        indicator.trackColor,
        const BoxColor.role(MaterialColorRole.surfaceContainerHighest),
      );
    });
  });
}
