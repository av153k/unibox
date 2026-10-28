import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

/// The ripple is a store like the page's: a press adds a drop, time advances it, and
/// the drop is gone when it has spread.
void main() {
  group('RippleStore', () {
    test('starts a drop where the press landed', () {
      final RippleStore store = RippleStore()..press(const BoxPoint(30, 12));

      expect(store.state.drops, hasLength(1));
      expect(store.state.drops.single.position, const BoxPoint(30, 12));
      expect(store.state.drops.single.progress, 0);

      store.onUnmount();
    });

    test('keeps a second press apart from the first', () {
      final RippleStore store = RippleStore()
        ..press(const BoxPoint(10, 10))
        ..press(const BoxPoint(90, 4));

      expect(store.state.drops, hasLength(2));
      expect(
        <BoxPoint>[
          for (final RippleDrop drop in store.state.drops) drop.position,
        ],
        <BoxPoint>[const BoxPoint(10, 10), const BoxPoint(90, 4)],
      );

      store.onUnmount();
    });

    test('advances a drop and forgets it when it has spread', () {
      final RippleStore store = RippleStore()..press(const BoxPoint(0, 0));

      store.advance(rippleDuration ~/ 2);
      expect(store.state.drops.single.progress, closeTo(0.5, 0.01));

      store.advance(rippleDuration ~/ 2);
      expect(store.state.drops, isEmpty);

      store.onUnmount();
    });

    test('publishing a drop notifies the view', () {
      final RippleStore store = RippleStore();
      var notified = 0;
      store.addListener(() => notified++);

      store.press(const BoxPoint(1, 2));
      expect(notified, 1);

      store.advance(rippleDuration ~/ 2);
      expect(notified, 2);

      store.onUnmount();
    });
  });

  group('RippleButton', () {
    test('draws the resting button before anything is pressed', () {
      final RippleButton button = RippleButton(
        label: 'Press me',
        background: const BoxColor(0xFF000000),
        foreground: const BoxColor(0xFFFFFFFF),
        ink: const BoxColor(0xFFFFFFFF),
        hover: const BoxColor(0xFF111111),
        radius: 20,
      );

      expect(validateTree(button), isEmpty);
    });
  });
}
