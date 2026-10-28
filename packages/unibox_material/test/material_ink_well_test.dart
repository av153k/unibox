import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

void _tap() {}

void main() {
  group('MaterialInkWell', () {
    test('is a box around the child it is given', () {
      final well = MaterialInkWell(child: const TextNode('Ada'));

      expect(well, isA<Box>());
      expect(well.children.single, isA<TextNode>());
      expect(well.transition, MaterialInkWell.defaultTransition);
    });

    test('tints its states with the palette layers', () {
      final well = MaterialInkWell(child: const TextNode('Ada'));

      expect(
        well.stateStyle(BoxState.hover)?.backgroundColor,
        const BoxColor.role(MaterialColorRole.hoverLayer),
      );
      expect(
        well.stateStyle(BoxState.focus)?.backgroundColor,
        const BoxColor.role(MaterialColorRole.focusLayer),
      );
      expect(
        well.stateStyle(BoxState.pressed)?.backgroundColor,
        const BoxColor.role(MaterialColorRole.pressedLayer),
      );
    });

    test('eases a tint over the short fade Material uses', () {
      expect(
        MaterialInkWell.defaultTransition.duration,
        const Duration(milliseconds: 100),
      );
    });

    test('is a button only when it can be tapped', () {
      final resting = MaterialInkWell(child: const TextNode('Ada'));
      final tappable = MaterialInkWell(
        child: const TextNode('Ada'),
        onTap: _tap,
      );

      expect(resting.semantics, isNull);
      expect(resting.isFocusable, isFalse);
      expect(tappable.semantics?.role, BoxRole.button);
      expect(tappable.isFocusable, isTrue);
    });

    test('lets a caller replace a state tint', () {
      final well = MaterialInkWell(
        child: const TextNode('Ada'),
        hoverStyle: const BoxStyle(backgroundColor: BoxColors.blue),
        pressedStyle: const BoxStyle(backgroundColor: BoxColors.red),
      );

      expect(well.stateStyle(BoxState.hover)?.backgroundColor, BoxColors.blue);
      expect(well.stateStyle(BoxState.pressed)?.backgroundColor, BoxColors.red);
    });
  });
}
