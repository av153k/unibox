import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';
import 'values.dart';

/// Renders a [core.Box] as a Flutter widget tree.
///
/// The box is built bottom-up: children, scroll viewport, padding, decoration,
/// clipping, dimensions, interactions and finally margin.
class UniboxBox extends StatefulWidget {
  /// Creates a renderer for [box].
  const UniboxBox({required this.box, super.key});

  /// The node being rendered.
  final core.Box box;

  @override
  State<UniboxBox> createState() => _UniboxBoxState();
}

class _UniboxBoxState extends State<UniboxBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final core.Box box = widget.box;
    final core.BoxStyle style = _hovered
        ? box.computedHoverStyle
        : box.computedStyle;

    Widget content = _buildContent(box, style);

    if (style.overflow == core.Overflow.scroll) {
      final core.Axis axis = style.direction ?? core.Axis.vertical;
      content = SingleChildScrollView(
        scrollDirection: toAxis(axis),
        child: content,
      );
    }

    final core.BoxSpacing? padding = style.padding;
    if (padding != null && !padding.isZero) {
      content = Padding(padding: toEdgeInsets(padding), child: content);
    }

    final BoxDecoration? decoration = toDecoration(style);
    if (decoration != null) {
      content = DecoratedBox(decoration: decoration, child: content);
    }

    if (style.overflow == core.Overflow.hidden) {
      content = ClipRect(child: content);
    }

    content = _applyDimensions(content, style);
    content = _applyInteractions(content, box);

    final core.BoxSpacing? margin = style.margin;
    if (margin != null && !margin.isZero) {
      content = Padding(padding: toEdgeInsets(margin), child: content);
    }

    return content;
  }

  /// Lays out the children, inserting `gap` separators between them.
  ///
  /// Without a [core.BoxStyle.direction] the children are stacked in a column,
  /// mirroring the block layout of a `<div>`.
  Widget _buildContent(core.Box box, core.BoxStyle style) {
    if (box.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final core.Axis? direction = style.direction;
    final double? gap = style.gap;
    final List<Widget> children = <Widget>[];

    for (var index = 0; index < box.children.length; index++) {
      if (direction != null && index > 0 && gap != null && gap > 0) {
        children.add(
          direction == core.Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
      children.add(_buildChild(box.children[index], direction));
    }

    if (direction == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    final MainAxisAlignment mainAxisAlignment = toMainAxisAlignment(
      style.mainAlign ?? core.MainAlign.start,
    );
    final CrossAxisAlignment crossAxisAlignment = toCrossAxisAlignment(
      style.crossAlign ?? core.CrossAlign.start,
    );

    if (direction == core.Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Renders [node] and makes it flexible along the parent's main axis when it
  /// declares a [core.BoxStyle.flex] factor or an infinite main dimension.
  Widget _buildChild(core.UINode node, core.Axis? direction) {
    final Widget child = renderNode(node);

    if (direction == null || node is! core.Box) {
      return child;
    }

    final core.BoxStyle childStyle = node.computedStyle;
    final double? mainSize = direction == core.Axis.horizontal
        ? childStyle.width
        : childStyle.height;
    final int? flex = childStyle.flex;
    final bool expands = mainSize == double.infinity;
    final bool hasFlex = flex != null && flex > 0;

    if (!expands && !hasFlex) {
      return child;
    }

    return Expanded(flex: hasFlex ? flex : 1, child: child);
  }

  /// Applies the fixed sizes and the min/max constraints of [style].
  Widget _applyDimensions(Widget content, core.BoxStyle style) {
    Widget result = content;

    if (style.width != null || style.height != null) {
      result = SizedBox(
        width: style.width,
        height: style.height,
        child: result,
      );
    }

    final BoxConstraints? constraints = toConstraints(style);
    if (constraints != null) {
      result = ConstrainedBox(constraints: constraints, child: result);
    }

    return result;
  }

  /// Wraps [content] with the tap, long press and hover handlers of [box].
  Widget _applyInteractions(Widget content, core.Box box) {
    final bool hovers = box.onHover != null || box.hasHoverStyle;

    if (!box.isInteractive && !hovers) {
      return content;
    }

    Widget result = content;

    if (box.isInteractive) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: box.onTap,
        onLongPress: box.onLongPress,
        child: result,
      );
    }

    return MouseRegion(
      cursor: box.isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (PointerEnterEvent event) => _setHovered(true),
      onExit: (PointerExitEvent event) => _setHovered(false),
      child: result,
    );
  }

  void _setHovered(bool hovered) {
    if (_hovered == hovered) {
      return;
    }

    setState(() {
      _hovered = hovered;
    });

    widget.box.onHover?.call(hovered);
  }
}
