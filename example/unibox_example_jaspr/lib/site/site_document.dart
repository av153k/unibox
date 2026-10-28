import 'package:jaspr/dom.dart' hide BoxShadow;
import 'package:jaspr/server.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_jaspr/unibox_jaspr.dart';
import 'package:unibox_material/unibox_material.dart';

import '../fonts.dart';
import 'iframe_node.dart';

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
    // The site is served from a subdirectory — `/unibox/` — so the default base
    // href of `/` would resolve every relative link, and both frames, against the
    // domain root: a page of 404s. No base element makes the browser resolve
    // against the document, which is what a page that links with `../` expects.
    base: null,
    title: switch (page) {
      SitePage.home => 'Unibox — one tree, two renderers',
      SitePage.material => 'Unibox — Material 3, as values and nodes',
      SitePage.showcase => 'Unibox — the same tree, drawn twice',
    },
    viewport: 'width=device-width, initial-scale=1',
    meta: <String, String>{
      'description': switch (page) {
        SitePage.home =>
          'Describe a screen once, in plain Dart, and draw it twice: Flutter '
              'widgets in an app and HTML with CSS in a browser.',
        SitePage.material =>
          'The Material 3 type scale, the colour roles and the components of '
              'Unibox, written as values and nodes that render the same on both '
              'targets.',
        SitePage.showcase =>
          'One Unibox node tree, drawn by Jaspr as HTML and CSS on the left and by '
              'Flutter on the right.',
      },
    },
    // The home document is the site root; the gallery and the showcase live one
    // directory below it.
    head: <Component>[fontFaces(page == SitePage.home ? '' : '../')],
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
            'font-family': "UniboxText, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
          },
        ),
      ),
    ],
    body: renderJaspr(
      // The gallery and the bar are built from material components, which name
      // colour roles: the document installs the palette as their theme.
      theme: MaterialPalette.lightTheme,
      buildSitePage(
        page,
        frame: ({required String src, required String title}) =>
            IframeNode(src: src, title: title),
      ),
    ),
  );
}

/// A colour as `RRGGBB`, for the one rule the frame writes as raw CSS.
String _hex(BoxColor color) {
  final String digits = color.value.toRadixString(16).padLeft(8, '0');
  return digits.substring(2).toUpperCase();
}
