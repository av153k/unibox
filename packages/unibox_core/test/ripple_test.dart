import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

/// The ripple is a token like any other, so it merges, compares and is printed like
/// one; the only thing that sets it apart is that it is motion, which is why the
/// appearance contract leaves it out.
void main() {
  group('BoxRipple', () {
    test('defaults to the model ink and a 450ms spread', () {
      const BoxRipple ripple = BoxRipple();

      expect(ripple.color, BoxRipple.defaultColor);
      expect(ripple.duration, BoxRipple.defaultDuration);
      expect(ripple.color.opacity, lessThan(0.2));
    });

    test('compares by ink and duration', () {
      expect(const BoxRipple(), const BoxRipple());
      expect(const BoxRipple(color: BoxColor.white), isNot(const BoxRipple()));
      expect(
        const BoxRipple(duration: Duration(milliseconds: 100)),
        isNot(const BoxRipple()),
      );
      expect(const BoxRipple().hashCode, const BoxRipple().hashCode);
      expect(
        const BoxRipple(
          color: BoxColor.white,
          duration: Duration(milliseconds: 100),
        ).toString(),
        contains('0xFFFFFFFF'),
      );
    });
  });

  group('Box.ripple', () {
    test('is a token of the bag, merged like the others', () {
      const BoxStyle base = BoxStyle(ripple: BoxRipple());
      const BoxStyle overlay = BoxStyle(
        ripple: BoxRipple(color: BoxColor.white),
      );

      expect(base.merge(overlay).ripple, overlay.ripple);
      expect(overlay.merge(base).ripple, base.ripple);
      expect(const BoxStyle().merge(base).ripple, base.ripple);
    });

    test('is reachable from the flat parameter, which wins over a bag', () {
      const Box box = Box(
        styles: <BoxStyle>[BoxStyle(ripple: BoxRipple())],
        ripple: BoxRipple(color: BoxColor.white),
      );

      expect(box.computedStyle.ripple, const BoxRipple(color: BoxColor.white));
      expect(const Box().computedStyle.ripple, isNull);
    });
  });
}
