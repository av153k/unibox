import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

void main() {
  group('MaterialTextField', () {
    test('is the label, the field and the message, in that order', () {
      final field = MaterialTextField(
        label: 'Email',
        value: 'ada@example.com',
        message: 'We only use it for the receipt.',
      );

      expect(field.children, hasLength(3));
      expect((field.children[0] as TextNode).text, 'Email');
      expect(field.children[1], isA<Box>());
      expect((field.children[2] as TextNode).text, contains('receipt'));
    });

    test('keeps the input, and its state, inside the outlined box', () {
      final field = MaterialTextField(
        label: 'Email',
        placeholder: 'you@example.com',
        required: true,
        invalid: true,
        description: 'Used for the receipt',
      );
      final input = (field.children[1] as Box).children.single as TextInputNode;

      expect(input.placeholder, 'you@example.com');
      expect(input.required, isTrue);
      expect(input.invalid, isTrue);
      expect(input.description, 'Used for the receipt');
    });

    test('draws the outline from the palette, one colour per state', () {
      BoxColor borderOf(MaterialTextField field) =>
          field.children.whereType<Box>().single.border?.color ??
          (throw StateError('expected a border'));

      const MaterialPalette palette = MaterialPalette.light;
      expect(borderOf(MaterialTextField()), palette.outline);
      expect(borderOf(MaterialTextField(focused: true)), palette.primary);
      expect(borderOf(MaterialTextField(invalid: true)), palette.error);
      // An invalid field is invalid whether or not it has focus.
      expect(
        borderOf(MaterialTextField(invalid: true, focused: true)),
        palette.error,
      );
    });

    test('typesets the text with the body role, in the on-surface colour', () {
      final field = MaterialTextField();
      final style = (field.children.single as Box).textStyle;

      expect(style?.color, MaterialPalette.light.onSurface);
      expect(style?.fontSize, MaterialTypography.bodyLarge.fontSize);
    });

    test('follows a dark palette', () {
      final field = MaterialTextField(palette: MaterialPalette.dark);
      final box = field.children.single as Box;

      expect(box.border?.color, MaterialPalette.dark.outline);
      expect(box.textStyle?.color, MaterialPalette.dark.onSurface);
    });

    test('is a single field when it has neither label nor message', () {
      expect(MaterialTextField().children, hasLength(1));
    });
  });

  group('MaterialTextField fidelity', () {
    Box outlineOf(MaterialTextField field) =>
        field.children.whereType<Box>().first;

    test('is at least 56 pixels tall', () {
      expect(outlineOf(MaterialTextField(label: 'Email')).minHeight, 56);
    });

    test('thickens the outline to 2 pixels when focused', () {
      final resting = outlineOf(MaterialTextField(label: 'Email'));
      final focused = outlineOf(
        MaterialTextField(label: 'Email', focused: true),
      );

      expect(resting.border?.width, 1);
      expect(focused.border?.width, 2);
    });

    test('darkens the outline on hover, but not while focused or invalid', () {
      final palette = MaterialPalette.light;

      expect(
        outlineOf(MaterialTextField()).hoverStyle?.border?.color,
        palette.onSurface,
      );
      expect(outlineOf(MaterialTextField(focused: true)).hoverStyle, isNull);
      expect(outlineOf(MaterialTextField(invalid: true)).hoverStyle, isNull);
    });

    test('fades to 38% when disabled', () {
      expect(outlineOf(MaterialTextField(enabled: false)).opacity, 0.38);
      expect(outlineOf(MaterialTextField()).opacity, isNull);
    });
  });
}
