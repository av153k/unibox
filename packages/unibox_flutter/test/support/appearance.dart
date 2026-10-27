import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_conformance/unibox_conformance.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

import 'harness.dart';

/// The presentation this renderer gave the root box of [pumpNode].
///
/// The facts are read from the widget tree the renderer built — the flex it
/// created, the padding it applied, the decoration it painted — and never from
/// the node tree, so they describe what this target *did* with the node. The
/// Jaspr suite reads the same facts out of the CSS its renderer emitted, and both
/// compare them with the table in `unibox_conformance`.
///
/// The rendered root node has to be a [core.Box]; a suite that renders anything
/// else is asking the wrong question.
BoxAppearance appearanceOf(WidgetTester tester) {
  final Element box = inNode(
    find.byWidgetPredicate((Widget widget) => widget is UniboxBox),
  ).evaluate().first;

  final List<Element> parts = _ownParts(box);
  final int flexIndex = parts.indexWhere((Element e) => e.widget is Flex);

  // Every box renders a flex container, so a box without one has lost its
  // layout: reporting the model defaults here would let that pass.
  if (flexIndex < 0) {
    throw StateError('The box was rendered without a flex container.');
  }

  final Flex flex = parts[flexIndex].widget as Flex;
  final int contentIndex = flexIndex;

  final SizedBox? sized = _sizedBoxBefore(parts, contentIndex);
  final BoxDecoration? decoration = _decorationBefore(parts, contentIndex);
  final List<EdgeInsets> paddings = _paddingsBefore(parts, contentIndex);

  final BorderRadius? radius = decoration?.borderRadius as BorderRadius?;
  final Border? border = decoration?.border as Border?;
  final BorderSide? side = border?.top;
  final Color? background = decoration?.color;

  return BoxAppearance(
    direction: _axisOf(flex.direction),
    mainAlign: _mainAlignOf(flex.mainAxisAlignment),
    crossAlign: _crossAlignOf(flex.crossAxisAlignment),
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
    // A baseline has no counterpart on the cross axis of a box, so a renderer
    // that aligned on it would be laying the box out differently.
    CrossAxisAlignment.baseline => throw StateError(
      'A box cannot align its children on a baseline.',
    ),
  };
}
