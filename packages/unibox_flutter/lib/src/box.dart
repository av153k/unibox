import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';
import 'text_style_scope.dart';
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
  bool _focused = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final core.Box box = widget.box;
    final core.BoxStyle style = _resolvedStyle(box);

    Widget content = _buildContent(box, style);

    final core.BoxTextStyle textStyle =
        style.textStyle ?? const core.BoxTextStyle();
    if (!textStyle.isEmpty) {
      content = _inheritTypography(context, content, textStyle);
    }

    if (style.overflow == core.Overflow.scroll) {
      content = SingleChildScrollView(
        scrollDirection: toAxis(style.resolvedDirection),
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

  /// Passes the typography of the box down to its descendants.
  ///
  /// The `DefaultTextStyle` makes Flutter's own widgets inherit the tokens, and
  /// the scope records the resolved typography for renderers that have to opt
  /// in, such as text fields. Only tokens the box sets are laid over the ambient
  /// style, so everything else keeps being inherited from the host application.
  Widget _inheritTypography(
    BuildContext context,
    Widget child,
    core.BoxTextStyle textStyle,
  ) {
    final core.BoxTextStyle inherited = UniboxTextStyleScope.of(context)
        .merge(textStyle);

    return DefaultTextStyle.merge(
      style: toTextStyle(textStyle),
      child: UniboxTextStyleScope(style: inherited, child: child),
    );
  }

  /// Lays out the children, inserting `gap` separators between them.
  ///
  /// The direction resolves to a column when the box does not name one (see
  /// [core.BoxStyle.resolvedDirection]), so `gap`, `mainAlign` and `crossAlign`
  /// apply to every box instead of only to the ones that spelled the direction
  /// out.
  Widget _buildContent(core.Box box, core.BoxStyle style) {
    if (box.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final core.Axis direction = style.resolvedDirection;
    final double? gap = style.gap;
    final List<Widget> children = <Widget>[];

    for (var index = 0; index < box.children.length; index++) {
      if (index > 0 && gap != null && gap > 0) {
        children.add(
          direction == core.Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
      children.add(_buildChild(box.children[index], direction));
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

  /// Renders [node] and makes it flexible along the parent's `direction` when it
  /// declares a [core.BoxStyle.flex] factor or an infinite main dimension.
  Widget _buildChild(core.UINode node, core.Axis direction) {
    final Widget child = renderNode(node);

    if (node is! core.Box) {
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

  /// Wraps [content] with the tap, keyboard, hover and semantics layers of [box].
  ///
  /// A disabled box keeps the same widget shape but serves no handler, no
  /// pointer cursor and no focus, so disabling never moves anything and only
  /// removes what the user can do.
  Widget _applyInteractions(Widget content, core.Box box) {
    final bool interactive = box.isInteractive;
    final bool focusable = box.isFocusable && box.enabled;
    final bool tracksState =
        box.enabled &&
        (box.onHover != null ||
            box.stateStyle(core.BoxState.hover) != null ||
            box.stateStyle(core.BoxState.focus) != null ||
            box.stateStyle(core.BoxState.pressed) != null);

    Widget result = content;

    if (box.onTap != null || box.onLongPress != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: interactive ? box.onTap : null,
        onLongPress: interactive ? box.onLongPress : null,
        onTapDown: interactive ? (TapDownDetails _) => _setPressed(true) : null,
        onTapUp: interactive ? (TapUpDetails _) => _setPressed(false) : null,
        onTapCancel: interactive ? () => _setPressed(false) : null,
        child: result,
      );
    }

    if (focusable) {
      result = Focus(
        onFocusChange: _setFocused,
        onKeyEvent: _handleKeyEvent,
        child: result,
      );
    }

    if (interactive || tracksState) {
      result = MouseRegion(
        cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: tracksState
            ? (PointerEnterEvent event) => _setHovered(true)
            : null,
        onExit: tracksState
            ? (PointerExitEvent event) => _setHovered(false)
            : null,
        child: result,
      );
    }

    return _describeToSemantics(result, box);
  }

  /// Activates the box from the keyboard.
  ///
  /// Enter and Space are what a button does everywhere: Enter fires on the way
  /// down, Space on the way up, and both show the pressed state in between.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final core.Box box = widget.box;
    final LogicalKeyboardKey key = event.logicalKey;
    final bool isActivationKey =
        key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space;

    if (!isActivationKey || !box.isInteractive) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      _setPressed(true);
      if (key == LogicalKeyboardKey.enter) {
        box.onTap?.call();
      }
      return KeyEventResult.handled;
    }

    if (event is KeyUpEvent) {
      _setPressed(false);
      if (key == LogicalKeyboardKey.space) {
        box.onTap?.call();
      }
    }

    return KeyEventResult.handled;
  }

  /// Describes [content] to assistive technologies.
  ///
  /// A plain enabled container is left untouched: an extra `Semantics` node on
  /// every box would only make the tree harder to read. A box with a description
  /// or a disabled state gets one, and so does a focusable box, which needs the
  /// focused flag to be announced.
  Widget _describeToSemantics(Widget content, core.Box box) {
    final core.BoxSemantics? semantics = box.semantics;
    final bool focusable = box.isFocusable && box.enabled;

    if (semantics == null && box.enabled) {
      return content;
    }

    final core.BoxRole role = semantics?.role ?? core.BoxRole.none;
    final bool? checked = semantics?.checked;
    final String? label = semantics?.label;

    return Semantics(
      container: semantics != null,
      // A label replaces the contents, so the accessible name cannot drift
      // away from what the screen reader reads.
      excludeSemantics: label != null,
      button: role == core.BoxRole.button,
      link: role == core.BoxRole.link,
      header: role == core.BoxRole.heading,
      checked: role == core.BoxRole.checkbox ? checked : null,
      toggled: role == core.BoxRole.switch_ ? checked : null,
      label: label,
      enabled: box.enabled,
      focusable: focusable,
      focused: focusable ? _focused : null,
      child: content,
    );
  }

  /// The style of [box] for the states it is in right now.
  ///
  /// States stack the way CSS pseudo classes do: the hovered tokens are laid
  /// over the resting style, then the focus and the press tokens, so a pressed
  /// hovered box keeps both.
  core.BoxStyle _resolvedStyle(core.Box box) {
    if (!box.enabled) {
      return box.computedStyleFor(core.BoxState.disabled);
    }

    core.BoxStyle style = box.computedStyle;

    if (_hovered) {
      style = style.merge(box.stateStyle(core.BoxState.hover));
    }
    if (_focused) {
      style = style.merge(box.stateStyle(core.BoxState.focus));
    }
    if (_pressed) {
      style = style.merge(box.stateStyle(core.BoxState.pressed));
    }

    return style;
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

  void _setFocused(bool focused) {
    if (_focused == focused) {
      return;
    }

    setState(() {
      _focused = focused;
    });
  }

  void _setPressed(bool pressed) {
    if (_pressed == pressed) {
      return;
    }

    setState(() {
      _pressed = pressed;
    });
  }
}
