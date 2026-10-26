import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

void main() {
  group('Box', () {
    test('defaults to an empty, style-less container', () {
      const box = Box();

      expect(box.children, isEmpty);
      expect(box.computedStyle, const BoxStyle());
      expect(box.hasHoverStyle, isFalse);
      expect(box.computedHoverStyle, const BoxStyle());
      expect(box.isInteractive, isFalse);
    });

    test('exposes children in order', () {
      const box = Box(children: [TextNode('a'), TextNode('b')]);

      expect(box.children, hasLength(2));
      expect((box.children.first as TextNode).text, 'a');
    });

    test('uses the style tokens when no flat parameter is given', () {
      const style = BoxStyle(
        direction: Axis.vertical,
        gap: 8,
        padding: BoxSpacing.all(12),
        backgroundColor: BoxColor.white,
      );
      const box = Box(style: style);

      expect(box.computedStyle, style);
    });

    test('flat parameters override matching style tokens', () {
      const style = BoxStyle(
        direction: Axis.vertical,
        gap: 8,
        padding: BoxSpacing.all(12),
        backgroundColor: BoxColor.white,
        width: 100,
      );
      const box = Box(
        style: style,
        direction: Axis.horizontal,
        gap: 24,
        backgroundColor: BoxColor.black,
      );

      final computed = box.computedStyle;

      expect(computed.direction, Axis.horizontal);
      expect(computed.gap, 24);
      expect(computed.backgroundColor, BoxColor.black);
      // Untouched style tokens survive the merge.
      expect(computed.padding, BoxSpacing.all(12));
      expect(computed.width, 100);
    });

    test('flat parameters are used without a style', () {
      const box = Box(
        direction: Axis.horizontal,
        mainAlign: MainAlign.spaceBetween,
        crossAlign: CrossAlign.stretch,
        gap: 4,
        flex: 2,
        overflow: Overflow.hidden,
        width: double.infinity,
        height: 40,
        minWidth: 10,
        maxWidth: 200,
        minHeight: 20,
        maxHeight: 300,
        padding: BoxSpacing.all(1),
        margin: BoxSpacing.all(2),
        backgroundColor: BoxColor.black,
        borderRadius: 6,
        border: BoxBorder(width: 2),
        shadow: BoxShadow(),
      );

      final computed = box.computedStyle;

      expect(computed.direction, Axis.horizontal);
      expect(computed.mainAlign, MainAlign.spaceBetween);
      expect(computed.crossAlign, CrossAlign.stretch);
      expect(computed.gap, 4);
      expect(computed.flex, 2);
      expect(computed.overflow, Overflow.hidden);
      expect(computed.width, double.infinity);
      expect(computed.height, 40);
      expect(computed.minWidth, 10);
      expect(computed.maxWidth, 200);
      expect(computed.minHeight, 20);
      expect(computed.maxHeight, 300);
      expect(computed.padding, BoxSpacing.all(1));
      expect(computed.margin, BoxSpacing.all(2));
      expect(computed.backgroundColor, BoxColor.black);
      expect(computed.borderRadius, 6);
      expect(computed.border, const BoxBorder(width: 2));
      expect(computed.shadow, const BoxShadow());
    });

    test('does not mutate the style it resolves', () {
      const style = BoxStyle(gap: 8);
      const box = Box(style: style, gap: 16);

      box.computedStyle;

      expect(style.gap, 8);
      expect(box.style, same(style));
    });

    test('hover style overlays the resting style', () {
      const style = BoxStyle(backgroundColor: BoxColor.white, borderRadius: 4);
      const hoverStyle = BoxStyle(backgroundColor: BoxColor.black);
      const box = Box(style: style, hoverStyle: hoverStyle);

      expect(box.hasHoverStyle, isTrue);
      expect(box.computedStyle.backgroundColor, BoxColor.white);
      expect(box.computedHoverStyle.backgroundColor, BoxColor.black);
      expect(box.computedHoverStyle.borderRadius, 4);
    });

    test('hover style wins over flat parameters while hovered', () {
      const box = Box(
        backgroundColor: BoxColor.white,
        hoverStyle: BoxStyle(backgroundColor: BoxColor.black),
      );

      expect(box.computedStyle.backgroundColor, BoxColor.white);
      expect(box.computedHoverStyle.backgroundColor, BoxColor.black);
    });

    test('resolves its typography from the style and the flat tokens', () {
      const box = Box(
        textStyle: BoxTextStyle(color: BoxColor.black),
        style: BoxStyle(
          textStyle: BoxTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

      expect(box.computedTextStyle.fontSize, 16);
      expect(box.computedTextStyle.fontWeight, FontWeight.bold);
      expect(box.computedTextStyle.color, BoxColor.black);
    });

    test('resolves an empty typography without a text style', () {
      expect(const Box().computedTextStyle.isEmpty, isTrue);
    });

    test('reports interactivity from its callbacks', () {
      expect(const Box(onTap: _noop).isInteractive, isTrue);
      expect(const Box(onLongPress: _noop).isInteractive, isTrue);
      expect(const Box().isInteractive, isFalse);
    });
  });
}

void _noop() {}
