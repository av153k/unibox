/// Material Design 3 typography for Unibox.
///
/// The package holds the fifteen roles of the Material 3 type scale as
/// `BoxTextStyle` values, so a tree can be typeset like a Material application
/// without taking a dependency on Flutter: the values are plain tokens, which
/// both renderers draw the same way.
///
/// ```dart
/// import 'package:unibox_core/unibox_core.dart';
/// import 'package:unibox_material/unibox_material.dart';
///
/// const Box(
///   textStyle: MaterialTypography.bodyMedium,
///   children: <UINode>[
///     TextNode('Order summary', style: MaterialTypography.titleLarge),
///     TextNode('Two nights, one room.'),
///   ],
/// );
/// ```
///
/// Typography, and the components built from it. The fifteen roles are plain
/// values a tree installs on a box or a text; [MaterialCard] and
/// [MaterialListTile] are nodes, because a card has children and a surface that
/// have to travel together, and a tile has parts that only make sense together. A look
/// is a value and a component is a node built from the node that already draws
/// it, so neither renderer has to know that this package exists.
///
/// Material's colour scheme, its elevation tones and its other components are
/// different axes, and each one needs a decision about how it maps onto a model
/// that has no theme layer yet.
library;

export 'src/material_card.dart';
export 'src/material_list_tile.dart';
export 'src/material_type_role.dart';
export 'src/material_typography.dart';
