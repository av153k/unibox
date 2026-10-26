import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

/// The boxes of the rendered tree, in document order, with the presentation each
/// one was actually given.
///
/// The facts are read from the widget tree the renderer built — the decoration it
/// painted, the padding it applied, the flex it created — and never from the node
/// tree, so they describe what this target does with the nodes. The web suite
/// reads the same facts out of the inline CSS its renderer emitted, and both are
/// compared against one fixture in `unibox_example_shared`.
List<BoxFact> boxFactsOf(WidgetTester tester) => <BoxFact>[
  for (final Element element in tester.allElements)
    if (element.widget is UniboxBox) _factsOf(element),
];

/// The facts of the box rendered by [box].
BoxFact _factsOf(Element box) {
  final List<Element> parts = _ownParts(box);
  final int flexIndex = parts.indexWhere((Element e) => e.widget is Flex);

  // Every box renders a flex container, so this is the layout the renderer
  // actually built. The fallback keeps the facts readable if a future renderer
  // ever skips the flex for a box that lays out nothing.
  final Flex? flex = flexIndex < 0 ? null : parts[flexIndex].widget as Flex;
  final int contentIndex = flexIndex < 0 ? parts.length : flexIndex;

  final SizedBox? sized = _sizedBoxBefore(parts, contentIndex);
  final BoxDecoration? decoration = _decorationBefore(parts, contentIndex);
  final List<EdgeInsets> paddings = _paddingsBefore(parts, contentIndex);

  final BorderRadius? radius = decoration?.borderRadius as BorderRadius?;
  final Border? border = decoration?.border as Border?;
  final BorderSide? side = border?.top;
  final Color? background = decoration?.color;

  return BoxFact(
    direction: flex == null ? core.Axis.vertical : _axisOf(flex.direction),
    mainAlign: flex == null
        ? core.MainAlign.start
        : _mainAlignOf(flex.mainAxisAlignment),
    crossAlign: flex == null
        ? core.CrossAlign.start
        : _crossAlignOf(flex.crossAxisAlignment),
    gap: _gapOf(parts, flexIndex),
    // A box applies its margin outside its padding, so in a pre-order walk the
    // margin comes first. A box with a single edge inset is reported as padded:
    // without a decoration to cover the inset, a margin and a padding of the same
    // size look identical anyway.
    padding: paddings.isEmpty ? null : _spacingOf(paddings.last),
    margin: paddings.length > 1 ? _spacingOf(paddings.first) : null,
    width: sized?.width,
    height: sized?.height,
    backgroundColor: background == null
        ? null
        : core.BoxColor(background.toARGB32()),
    borderRadius: radius?.topLeft.x,
    borderWidth: side?.width,
    borderColor: side == null ? null : core.BoxColor(side.color.toARGB32()),
  );
}

/// Every element of the subtree of [box], up to but excluding the widgets of the
/// nodes below it.
///
/// A nested node renders its own facts, so the walk has to stop at its renderer:
/// otherwise a box would report the decoration and the padding of its children.
List<Element> _ownParts(Element box) {
  final List<Element> parts = <Element>[];

  void visit(Element element) {
    parts.add(element);
    element.visitChildElements((Element child) {
      if (_isNodeRenderer(child.widget)) {
        return;
      }
      visit(child);
    });
  }

  visit(box);
  return parts;
}

/// Whether [widget] renders a node of the tree, and therefore starts a new fact.
bool _isNodeRenderer(Widget widget) {
  return widget is UniboxBox ||
      widget is UniboxText ||
      widget is UniboxTextInput ||
      widget is UniboxLink ||
      widget is UniboxImage ||
      widget is UniboxStack;
}

/// The box the renderer sized this node with, if the node declares a size.
SizedBox? _sizedBoxBefore(List<Element> parts, int end) {
  for (var index = 0; index < end; index++) {
    final Widget widget = parts[index].widget;
    if (widget is SizedBox && (widget.width != null || widget.height != null)) {
      return widget;
    }
  }
  return null;
}

/// The decoration the renderer painted behind this node.
BoxDecoration? _decorationBefore(List<Element> parts, int end) {
  for (var index = 0; index < end; index++) {
    final Widget widget = parts[index].widget;
    if (widget is DecoratedBox && widget.decoration is BoxDecoration) {
      return widget.decoration as BoxDecoration;
    }
  }
  return null;
}

/// The edge insets the renderer applied to this node, outermost first.
List<EdgeInsets> _paddingsBefore(List<Element> parts, int end) {
  final List<EdgeInsets> paddings = <EdgeInsets>[];

  for (var index = 0; index < end; index++) {
    final Widget widget = parts[index].widget;
    if (widget is! Padding) {
      continue;
    }

    final EdgeInsetsGeometry padding = widget.padding;
    if (padding is EdgeInsets) {
      paddings.add(padding);
    }
  }

  return paddings;
}

/// The space the renderer put between two children of the flex at [flexIndex].
double? _gapOf(List<Element> parts, int flexIndex) {
  if (flexIndex < 0) {
    return null;
  }

  for (var index = flexIndex + 1; index < parts.length; index++) {
    final Widget widget = parts[index].widget;
    if (widget is SizedBox && widget.child == null) {
      return widget.width ?? widget.height;
    }
  }

  return null;
}

/// The core spacing of a Flutter edge inset.
core.BoxSpacing _spacingOf(EdgeInsets insets) {
  return core.BoxSpacing(
    top: insets.top,
    right: insets.right,
    bottom: insets.bottom,
    left: insets.left,
  );
}

/// The core axis of a Flutter axis.
core.Axis _axisOf(Axis axis) {
  return axis == Axis.horizontal ? core.Axis.horizontal : core.Axis.vertical;
}

/// The core alignment of a Flutter main axis alignment.
core.MainAlign _mainAlignOf(MainAxisAlignment align) {
  return switch (align) {
    MainAxisAlignment.start => core.MainAlign.start,
    MainAxisAlignment.end => core.MainAlign.end,
    MainAxisAlignment.center => core.MainAlign.center,
    MainAxisAlignment.spaceBetween => core.MainAlign.spaceBetween,
    MainAxisAlignment.spaceAround => core.MainAlign.spaceAround,
    MainAxisAlignment.spaceEvenly => core.MainAlign.spaceEvenly,
  };
}

/// The core alignment of a Flutter cross axis alignment.
core.CrossAlign _crossAlignOf(CrossAxisAlignment align) {
  return switch (align) {
    CrossAxisAlignment.start => core.CrossAlign.start,
    CrossAxisAlignment.end => core.CrossAlign.end,
    CrossAxisAlignment.center => core.CrossAlign.center,
    CrossAxisAlignment.stretch => core.CrossAlign.stretch,
    // A baseline has no counterpart on the cross axis of a box.
    CrossAxisAlignment.baseline => core.CrossAlign.start,
  };
}
