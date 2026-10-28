import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

/// A press is an event rather than a pair of numbers, so the type has to behave like
/// one: comparable, printable, and optional on the node.
void main() {
  group('BoxPoint', () {
    test('compares by its two numbers', () {
      expect(const BoxPoint(1, 2), const BoxPoint(1, 2));
      expect(const BoxPoint(1, 2), isNot(const BoxPoint(2, 1)));
      expect(const BoxPoint(1, 2).hashCode, const BoxPoint(1, 2).hashCode);
      expect(const BoxPoint(1, 2).toString(), 'BoxPoint(1.0, 2.0)');
    });
  });

  group('BoxTapEvent', () {
    test('carries the local position and what pressed it', () {
      const BoxTapEvent event = BoxTapEvent(
        position: BoxPoint(12, 8),
        pointer: BoxPointerKind.pen,
      );

      expect(event.position, const BoxPoint(12, 8));
      expect(event.pointer, BoxPointerKind.pen);
    });

    test('defaults to a pointer the host could not name', () {
      expect(
        const BoxTapEvent(position: BoxPoint(0, 0)).pointer,
        BoxPointerKind.unknown,
      );
    });

    test('compares by both fields', () {
      const BoxTapEvent event = BoxTapEvent(
        position: BoxPoint(1, 2),
        pointer: BoxPointerKind.touch,
      );

      expect(
        event,
        const BoxTapEvent(
          position: BoxPoint(1, 2),
          pointer: BoxPointerKind.touch,
        ),
      );
      expect(event, isNot(const BoxTapEvent(position: BoxPoint(1, 2))));
      expect(event.hashCode, event.hashCode);
      expect(event.toString(), contains('touch'));
    });
  });

  group('Box.onTapDown', () {
    test('is a callback the box carries, separate from onTap', () {
      BoxTapEvent? seen;

      final Box box = Box(onTapDown: (BoxTapEvent event) => seen = event);

      expect(box.onTap, isNull);
      expect(box.onTapDown, isNotNull);

      box.onTapDown!(const BoxTapEvent(position: BoxPoint(4, 6)));

      expect(seen?.position, const BoxPoint(4, 6));
    });

    test('is unset on a box that only activates', () {
      final Box box = Box(onTap: () {});

      expect(box.onTapDown, isNull);
      expect(box.isInteractive, isTrue);
    });
  });
}
