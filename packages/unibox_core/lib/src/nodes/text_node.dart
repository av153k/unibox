import '../enums.dart';
import '../tokens/box_color.dart';
import 'ui_node.dart';

/// A run of text.
class TextNode extends UINode {
  /// Creates a text node.
  const TextNode(
    this.text, {
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// The text content.
  final String text;

  /// The font size in logical pixels.
  final double? fontSize;

  /// The weight of the font.
  final FontWeight? fontWeight;

  /// The text color.
  final BoxColor? color;

  /// The horizontal alignment of the text.
  final TextAlign? textAlign;

  /// The maximum number of lines to display.
  final int? maxLines;

  /// How text that does not fit is truncated.
  final TextOverflow? overflow;
}
