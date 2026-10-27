import 'package:jaspr/dom.dart' hide BoxShadow;
import 'package:jaspr/server.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_jaspr/unibox_jaspr.dart';
import 'package:unibox_material/unibox_material.dart';

import 'gallery.dart';
import 'showcase.dart';

/// The pages the site publishes.
///
/// The paths are relative to the site root, because a project site is served from
/// a subdirectory (`/unibox/`) and an absolute `/showcase/` would leave it. A page
/// links to another one by walking up its own depth, which is why the depth is part
/// of the entry rather than a number written into each page.
enum SitePage {
  /// The Material library: the type scale, the palette and the components.
  material('Material', '', 0),

  /// The same node tree drawn by both renderers, side by side.
  showcase('Showcase', 'showcase/', 1);

  const SitePage(this.label, this.path, this.depth);

  /// The label of the destination in the bar.
  final String label;

  /// The path below the site root, empty for the root page.
  final String path;

  /// How many directories deep the page is served.
  final int depth;

  /// The href of this destination, from [from].
  String hrefFrom(SitePage from) {
    final String up = '../' * from.depth;
    return path.isEmpty ? (up.isEmpty ? './' : up) : '$up$path';
  }
}

/// The frame every page is drawn in: the bar and [page].
///
/// The frame is a node tree like any other page — the site is built with the
/// library it documents. [fill] gives the page the height of the window, which the
/// showcase needs for its two frames and the gallery does not.
UINode buildSiteFrame({
  required SitePage current,
  required UINode page,
  bool fill = false,
}) {
  final MaterialPalette palette = MaterialPalette.light;

  return Box(
    direction: Axis.vertical,
    width: double.infinity,
    height: fill ? double.infinity : null,
    backgroundColor: palette.surface,
    textStyle: MaterialTypography.bodyMedium.merge(
      BoxTextStyle(color: palette.onSurface),
    ),
    children: <UINode>[
      _bar(current, palette),
      if (fill)
        Box(flex: 1, width: double.infinity, children: <UINode>[page])
      else
        page,
    ],
  );
}

/// The bar above every page: the name of the site and its two destinations.
///
/// The hairline is a shadow with no blur, because a `BoxBorder` draws on all four
/// sides and a bar needs one line. The links are `LinkNode`s, so the website is
/// crawlable and works without JavaScript.
UINode _bar(SitePage current, MaterialPalette palette) {
  return Box(
    direction: Axis.horizontal,
    mainAlign: MainAlign.spaceBetween,
    crossAlign: CrossAlign.center,
    width: double.infinity,
    padding: const BoxSpacing.symmetric(horizontal: 24, vertical: 12),
    backgroundColor: palette.surface,
    semantics: const BoxSemantics(element: BoxElement.nav),
    shadow: BoxShadow(color: palette.outlineVariant, offsetY: 1, blurRadius: 0),
    children: <UINode>[
      LinkNode(
        SitePage.material.hrefFrom(current),
        child: TextNode('Unibox', style: MaterialTypography.titleMedium),
      ),
      Box(
        direction: Axis.horizontal,
        crossAlign: CrossAlign.center,
        gap: 4,
        children: <UINode>[
          for (final SitePage page in SitePage.values)
            _navigationItem(
              page,
              current: page == current,
              from: current,
              palette: palette,
            ),
        ],
      ),
    ],
  );
}

/// One destination: a link, tinted while its page is open.
UINode _navigationItem(
  SitePage page, {
  required bool current,
  required SitePage from,
  required MaterialPalette palette,
}) {
  return LinkNode(
    page.hrefFrom(from),
    child: Box(
      padding: const BoxSpacing.symmetric(horizontal: 12, vertical: 6),
      borderRadius: 8,
      backgroundColor: current ? palette.surfaceContainerHighest : null,
      children: <UINode>[
        TextNode(
          page.label,
          style: current
              ? MaterialTypography.labelLarge
              : MaterialTypography.bodyMedium,
        ),
      ],
    ),
  );
}

/// The document a page of the site is served as.
///
/// The metadata belongs to the document, not to the tree: a title and a description
/// describe a page. `fill` is the browser half of [buildSiteFrame]'s `fill` — the
/// percentage heights of the showcase need a root with a height to resolve against,
/// and the body margin has to go or it paints a frame nothing in the tree asked for.
Document buildSiteDocument({required SitePage page}) {
  final MaterialPalette palette = MaterialPalette.light;

  return Document(
    lang: 'en',
    title: page == SitePage.material
        ? 'Unibox — Material 3, as values and nodes'
        : 'Unibox — the same tree, drawn twice',
    viewport: 'width=device-width, initial-scale=1',
    meta: <String, String>{
      'description': page == SitePage.material
          ? 'The Material 3 type scale, the colour roles and the components of '
                'Unibox, written as values and nodes that render the same on both '
                'targets.'
          : 'One Unibox node tree, drawn by Jaspr as HTML and CSS on the left and by '
                'Flutter on the right.',
    },
    styles: <StyleRule>[
      StyleRule(
        selector: const Selector('html, body'),
        styles: Styles(height: const Unit.percent(100), margin: Spacing.zero),
      ),
      StyleRule(
        selector: const Selector('body'),
        styles: Styles(
          raw: <String, String>{
            'background-color': '#${_hex(palette.surface)}',
            'font-family':
                "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
          },
        ),
      ),
    ],
    body: renderJaspr(
      buildSiteFrame(
        current: page,
        fill: page == SitePage.showcase,
        page: switch (page) {
          SitePage.material => buildMaterialGallery(),
          SitePage.showcase => buildShowcase(),
        },
      ),
    ),
  );
}

/// A colour as `RRGGBB`, for the one rule the frame writes as raw CSS.
String _hex(BoxColor color) {
  final String digits = color.value.toRadixString(16).padLeft(8, '0');
  return digits.substring(2).toUpperCase();
}
