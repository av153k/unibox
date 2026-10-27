import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

void main() {
  group('MaterialIcon', () {
    test('is a square holding one glyph in the icon font', () {
      final icon = MaterialIcon('home');
      final glyph = icon.children.single as TextNode;

      expect(icon, isA<Box>());
      expect(icon.width, 24);
      expect(icon.height, 24);
      expect(glyph.text, 'home');
      expect(icon.textStyle?.fontFamily, 'Material Symbols Outlined');
      expect(icon.textStyle?.fontSize, 24);
      expect(icon.textStyle?.lineHeight, 1);
      expect(icon.textStyle?.color, MaterialPalette.light.onSurfaceVariant);
    });

    test('scales its glyph with its size and takes a colour', () {
      final icon = MaterialIcon('delete', size: 40, color: BoxColors.red);

      expect(icon.width, 40);
      expect(icon.textStyle?.fontSize, 40);
      expect(icon.textStyle?.color, BoxColors.red);
    });

    test('draws a code point as the character it names', () {
      final icon = MaterialIcon.codePoint(0xe88a);

      expect(
        (icon.children.single as TextNode).text,
        String.fromCharCode(0xe88a),
      );
    });

    test('hides a decorative icon and announces a labelled one', () {
      expect(MaterialIcon('home').semantics?.hidden, isTrue);

      final labelled = MaterialIcon('home', label: 'Home');
      expect(labelled.semantics?.hidden, isFalse);
      expect(labelled.semantics?.label, 'Home');
    });

    test('follows the palette and the family it is given', () {
      final icon = MaterialIcon(
        'home',
        palette: MaterialPalette.dark,
        fontFamily: 'Material Icons',
      );

      expect(icon.textStyle?.color, MaterialPalette.dark.onSurfaceVariant);
      expect(icon.textStyle?.fontFamily, 'Material Icons');
    });
  });
}
