import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';

/// Renders a [core.GridNode]: equal columns, computed from the box it is given.
///
/// The count and the cell width come from [core.GridNode.columnsFor] and
/// [core.GridNode.cellWidthFor], the arithmetic the web renderer writes as
/// `repeat(auto-fill, minmax(min(100%, …), 1fr))` — so both targets read the
/// same rule, one from CSS and one from the constraints of the grid itself.
///
/// A short last row is **padded with empty slots** of the same width. `auto-fill`
/// creates every track whether or not a card lands in it, so a row of two cards in
/// a three-track grid leaves the third track empty; stretching the two cards over
/// it would be a different layout on the two targets, which is why nothing here
/// uses `Expanded` or `Flexible`.
///
/// Every card is top-aligned in its row (`align-items: start` on the web), so a
/// row is as tall as its tallest card and shorter cards are not stretched.
class FlutterGrid extends StatelessWidget {
  /// Creates a renderer for [node].
  const FlutterGrid({required this.node, super.key});

  /// The node being rendered.
  final core.GridNode node;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = node.columnsFor(width);
        final double cell = node.cellWidthFor(width);
        final List<Widget> rows = <Widget>[];

        for (int start = 0; start < node.children.length; start += columns) {
          if (start > 0 && node.gap > 0) {
            rows.add(SizedBox(height: node.gap));
          }

          rows.add(
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _slots(start, columns, cell),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }

  /// One track per column, empty when [start] runs out of cards.
  List<Widget> _slots(int start, int columns, double cell) {
    final List<Widget> slots = <Widget>[];

    for (int column = 0; column < columns; column++) {
      if (column > 0 && node.gap > 0) {
        slots.add(SizedBox(width: node.gap));
      }

      final int index = start + column;

      slots.add(
        SizedBox(
          width: cell,
          child: index < node.children.length
              ? renderNode(node.children[index])
              : null,
        ),
      );
    }

    return slots;
  }
}
