import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_testing/unibox_testing.dart';

void main() {
  group('overlayCases', () {
    test('start from an overlay without tokens', () {
      final OverlayCase plain = overlayCases.first;

      expect(plain.expected, const OverlayAppearance());
      expect(plain.node.alignment, core.OverlayAlignment.center);
      expect(plain.node.barrierColor, core.OverlayNode.defaultBarrierColor);
    });

    test('let every case except the first change the plain overlay', () {
      for (final OverlayCase overlayCase in overlayCases.skip(1)) {
        expect(
          overlayCase.expected,
          isNot(overlayCases.first.expected),
          reason: '"${overlayCase.description}" expects the plain overlay.',
        );
      }
    });

    test('expect a different presentation for every case', () {
      final Set<OverlayAppearance> distinct = overlayCases
          .map((OverlayCase overlayCase) => overlayCase.expected)
          .toSet();

      expect(distinct, hasLength(overlayCases.length));
    });

    test('carry every token in the last case', () {
      final OverlayAppearance everyToken = overlayCases.last.expected;

      expect(everyToken.alignment, isNot(core.OverlayAlignment.center));
      expect(
        everyToken.barrierColor,
        isNot(core.OverlayNode.defaultBarrierColor),
      );
    });

    test('name the token that drifted', () {
      expect(
        const OverlayAppearance(alignment: core.OverlayAlignment.top)
            .differencesFrom(const OverlayAppearance())
            .keys,
        contains('alignment'),
      );
    });
  });
}
