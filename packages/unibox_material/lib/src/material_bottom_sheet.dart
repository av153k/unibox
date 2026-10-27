import 'package:unibox_core/unibox_core.dart';

import 'material_dialog.dart';
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
           maxWidth: maxWidth,
           shadow: MaterialDialog.elevation,
           children: <UINode>[
             TextNode(
               title,
               style: MaterialTypography.headlineSmall.merge(
                 BoxTextStyle(color: palette.onSurface),
               ),
             ),
             ?content,
             if (actions.isNotEmpty)
               Box(
                 direction: Axis.horizontal,
                 mainAlign: MainAlign.end,
                 gap: 8,
                 children: actions,
               ),
           ],
         ),
       );
}
