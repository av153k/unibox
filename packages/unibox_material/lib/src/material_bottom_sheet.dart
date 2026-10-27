import 'package:unibox_core/unibox_core.dart';

import 'material_palette.dart';
import 'material_typography.dart';

/// A Material 3 bottom sheet: an [OverlayNode] against the bottom edge, holding a
/// title, a body and the sheet's own actions.
///
/// ```dart
/// MaterialBottomSheet(
///   title: 'Filter listings',
///   content: FilterForm(state: state, store: store),
///   actions: <UINode>[ApplyButton(onTap: store.applyFilters)],
///   onDismiss: store.closeFilters,
/// )
/// ```
///
/// It is a [MaterialDialog] that sits at the bottom and reads as a sheet rather
/// than a card: the same scrim, the same dismissal policy, the same title and
/// action treatment, a lower surface tone and a wider bound.
///
/// **What it is not.** Material squares the two corners that meet the screen edge;
/// the model has one radius per box, so all four are rounded — the difference shows
/// only where the sheet meets the edge of the screen.
final class MaterialBottomSheet extends OverlayNode {
  /// Creates the sheet.
  MaterialBottomSheet({
    super.key,
    required String title,
    UINode? content,
    List<UINode> actions = const <UINode>[],
    super.onDismiss,
    super.barrierDismissible,
    MaterialPalette palette = MaterialPalette.light,
    double maxWidth = 640,
  }) : super(
         barrierColor: palette.scrim,
         alignment: OverlayAlignment.bottom,
         child: Box(
           backgroundColor: palette.surfaceContainerLow,
           borderRadius: 28,
           padding: const BoxSpacing.all(24),
           gap: 16,
           width: double.infinity,
           maxWidth: maxWidth,
           shadow: _elevation,
           children: <UINode>[
             Box(
               mainAlign: MainAlign.center,
               children: <UINode>[
                 Box(
                   width: 32,
                   height: 4,
                   borderRadius: 2,
                   backgroundColor: palette.onSurfaceVariant.withOpacity(0.4),
                 ),
               ],
             ),
             TextNode(
               title,
               style: MaterialTypography.headlineSmall.merge(
                 BoxTextStyle(color: palette.onSurface),
               ),
             ),
             if (content != null)
               Box(
                 textStyle: MaterialTypography.bodyMedium.merge(
                   BoxTextStyle(color: palette.onSurfaceVariant),
                 ),
                 children: <UINode>[content],
               ),
             if (actions.isNotEmpty)
               Box(
                 direction: Axis.horizontal,
                 mainAlign: MainAlign.end,
                 gap: 8,
                 textStyle: MaterialTypography.labelLarge.merge(
                   BoxTextStyle(color: palette.primary),
                 ),
                 children: actions,
               ),
           ],
         ),
       );

  /// Elevation level one, cast upward: the sheet rises from the bottom edge.
  static const BoxShadow _elevation = BoxShadow(
    color: BoxColor.rgba(0, 0, 0, 0x26),
    offsetY: -1,
    blurRadius: 3,
  );
}
