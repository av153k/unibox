import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

import 'iframe_node.dart';

/// The same node tree, drawn twice: the web rendering on the left and the Flutter
/// build of it on the right.
///
/// Two frames rather than two links, because the point is the comparison: resize the
/// window and both answer the same breakpoint, on the same node tree. The page is a
/// node tree as well — the bar and the two captions are boxes and texts, and the
/// frames are the one thing the model cannot describe, so they arrive through
/// [EmbedNode].
UINode buildShowcase() {
  const MaterialPalette palette = MaterialPalette.light;

  return Box(
    direction: Axis.horizontal,
    width: double.infinity,
    height: double.infinity,
    gap: 1,
    backgroundColor: palette.outlineVariant,
    children: <UINode>[
      _panel(title: 'Jaspr — HTML and CSS', src: '../web/', palette: palette),
      _panel(
        title: 'Flutter — the same tree',
        src: '../flutter/',
        palette: palette,
      ),
    ],
  );
}

/// One half of the comparison: a caption and the frame under it.
UINode _panel({
  required String title,
  required String src,
  required MaterialPalette palette,
}) {
  return Box(
    flex: 1,
    direction: Axis.vertical,
    height: double.infinity,
    backgroundColor: palette.surface,
    children: <UINode>[
      Box(
        width: double.infinity,
        padding: const BoxSpacing.symmetric(horizontal: 16, vertical: 10),
        children: <UINode>[
          TextNode(
            title,
            style: MaterialTypography.labelMedium.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
        ],
      ),
      Box(
        flex: 1,
        width: double.infinity,
        children: <UINode>[IframeNode(src: src, title: title)],
      ),
    ],
  );
}
