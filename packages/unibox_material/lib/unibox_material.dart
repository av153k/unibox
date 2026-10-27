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
/// Only typography lives here. Colours, elevation, shape and components are
/// different axes of Material, and each one needs a decision about how it maps
/// onto a model that has no theme layer yet.
library;

export 'src/material_type_role.dart';
export 'src/material_typography.dart';
