import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

void _tap() {}

/// The column of text inside a tile, whether or not it has a leading node.
Box _textColumn(MaterialListTile tile) =>
    tile.children.firstWhere((UINode node) => node is Box) as Box;

void main() {
  group('MaterialListTile', () {
    test('is a box with the arrangement Material gives a tile', () {
      final tile = MaterialListTile(title: const TextNode('Ada'));

      expect(tile, isA<Box>());
      expect(tile.direction, Axis.horizontal);
      expect(tile.crossAlign, CrossAlign.center);
      expect(tile.width, double.infinity);
      expect(tile.gap, 16);
      expect(
        tile.padding,
        const BoxSpacing.symmetric(horizontal: 16, vertical: 8),
      );
      expect(tile.backgroundColor, isNull);
      expect(tile.children, hasLength(1));
    });

    test('sizes itself to the one line and two line heights of Material', () {
      final oneLine = MaterialListTile(title: const TextNode('Ada'));
      final twoLine = MaterialListTile(
        title: const TextNode('Ada'),
        subtitle: const TextNode('ada@example.com'),
      );
      final denseOneLine = MaterialListTile(
        title: const TextNode('Ada'),
        dense: true,
      );
      final denseTwoLine = MaterialListTile(
        title: const TextNode('Ada'),
        subtitle: const TextNode('ada@example.com'),
        dense: true,
      );

      expect(oneLine.minHeight, 56);
      expect(twoLine.minHeight, 72);
      expect(denseOneLine.minHeight, 48);
      expect(denseTwoLine.minHeight, 64);
    });

    test('lays the leading node, the text and the trailing node in a row', () {
      final tile = MaterialListTile(
        leading: const TextNode('AL'),
        title: const TextNode('Ada'),
        subtitle: const TextNode('ada@example.com'),
        trailing: const TextNode('2m'),
      );

      expect(tile.children, hasLength(3));
      expect((tile.children.first as TextNode).text, 'AL');
      expect((tile.children.last as TextNode).text, '2m');

      final Box column = tile.children[1] as Box;
      expect(column.flex, 1);
      expect(column.direction, Axis.vertical);
      expect(column.children, hasLength(2));
    });

    test('typesets the title and the subtitle the way Material does', () {
      final tile = MaterialListTile(
        title: const TextNode('Ada'),
        subtitle: const TextNode('ada@example.com'),
      );

      final Box column = _textColumn(tile);
      expect(
        column.textStyle,
        MaterialTypography.bodyLarge.merge(
          BoxTextStyle(color: MaterialPalette.light.onSurface),
        ),
      );

      final Box subtitleBox = column.children.last as Box;
      expect(
        subtitleBox.textStyle,
        MaterialTypography.bodyMedium.merge(
          BoxTextStyle(color: MaterialPalette.light.onSurfaceVariant),
        ),
      );

      // The subtitle is `bodyMedium` with a colour, so the two cannot drift.
      const BoxTextStyle subtitle = MaterialListTile.subtitleTextStyle;
      final BoxTextStyle body = MaterialTypography.bodyMedium;

      expect(subtitle.fontSize, body.fontSize);
      expect(subtitle.fontWeight, body.fontWeight);
      expect(subtitle.lineHeight, body.lineHeight);
      expect(subtitle.letterSpacing, body.letterSpacing);
      expect(subtitle.color, MaterialListTile.subtitleColor);
    });

    test('is a button only when it can be tapped', () {
      final resting = MaterialListTile(title: const TextNode('Ada'));
      final tappable = MaterialListTile(
        title: const TextNode('Ada'),
        onTap: _tap,
      );

      expect(resting.semantics, isNull);
      expect(resting.isFocusable, isFalse);
      expect(tappable.semantics?.role, BoxRole.button);
      expect(tappable.isFocusable, isTrue);
    });

    test('keeps the semantics it is given', () {
      final tile = MaterialListTile(
        title: const TextNode('Ada'),
        onTap: _tap,
        semantics: const BoxSemantics(role: BoxRole.link, label: 'Contact'),
      );

      expect(tile.semantics?.role, BoxRole.link);
      expect(tile.semantics?.label, 'Contact');
    });

    test('tints itself on hover and press, and lets a caller replace it', () {
      final tile = MaterialListTile(title: const TextNode('Ada'));
      final themed = MaterialListTile(
        title: const TextNode('Ada'),
        hoverStyle: const BoxStyle(backgroundColor: BoxColors.blue),
        stateStyles: const <BoxState, BoxStyle>{},
      );

      expect(
        tile.stateStyle(BoxState.hover)?.backgroundColor,
        MaterialPalette.light.hoverLayer,
      );
      expect(
        tile.stateStyle(BoxState.pressed)?.backgroundColor,
        MaterialPalette.light.pressedLayer,
      );
      expect(
        themed.stateStyle(BoxState.hover)?.backgroundColor,
        BoxColors.blue,
      );
      expect(themed.stateStyle(BoxState.pressed), isNull);
    });

    test('lets a caller replace every tile token', () {
      final tile = MaterialListTile(
        title: const TextNode('Ada'),
        subtitle: const TextNode('ada@example.com'),
        color: BoxColors.darkGrey,
        width: 320,
        padding: const BoxSpacing.all(8),
        gap: 8,
        minHeight: 40,
        titleStyle: const BoxTextStyle(fontSize: 18),
        subtitleStyle: const BoxTextStyle(fontSize: 12),
      );

      final BoxStyle style = tile.computedStyle;

      expect(style.backgroundColor, BoxColors.darkGrey);
      expect(style.width, 320);
      expect(style.minHeight, 40);
      expect(style.padding, const BoxSpacing.all(8));
      expect(style.gap, 8);
      expect(_textColumn(tile).textStyle, const BoxTextStyle(fontSize: 18));
    });
  });
}
