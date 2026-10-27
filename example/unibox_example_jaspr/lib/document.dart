import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

import 'main.dart';

/// The document the example is served as.
///
/// The page box centres itself in a surface that fills the viewport — `width`
/// and `height: double.infinity` render as `100%` — so the root elements have to
/// give that percentage something to resolve against. Without `height: 100%`
/// the page box collapses to the height of its content, which is a state a
/// Flutter host never gets into: a `Scaffold` body is as tall as the window, so
/// the card ends up in the middle of the screen there and at the top of a short
/// grey strip here. The same height is what the apartments page scrolls inside
/// instead of growing the document.
///
/// The default body margin is removed for the same reason. Flutter lays the page
/// box out edge to edge, and the eight pixels a browser reserves around a body
/// would show up as a white frame around the canvas colour that nothing in the
/// node tree asked for.
///
/// Both rules describe the *host*, not the tree: they are the browser equivalent
/// of the surface a Flutter application is given, which is why they live next to
/// the app instead of in the renderer.
///
/// [page] is the destination the export starts on, which is the listings. Being
/// open is state, so a static export cannot open anything by itself:
/// `bin/build.dart` writes one document per destination, and the sign-up document
/// starts with the dialog open while the entry document starts with it closed.
///
/// The metadata is the host's, not the tree's: a title and a description describe
/// a *document*, while a node tree describes a region of one. That is also why
/// each page gets its own: two documents that share a title look like one page
/// twice to a search engine. A host that needs more — a canonical url, Open Graph
/// tags, structured data — adds them through `Document.head`, which is where
/// elements that do not belong to the tree go.
Document buildExampleDocument({ExamplePage page = ExamplePage.apartments}) {
  return Document(
    // Without `lang` both a screen reader and a crawler have to guess which
    // language the page is in.
    lang: 'en',
    title: _titleOf(page),
    viewport: 'width=device-width, initial-scale=1',
    meta: <String, String>{'description': _descriptionOf(page)},
    styles: <StyleRule>[
      StyleRule(
        selector: const Selector('html, body'),
        styles: Styles(height: const Unit.percent(100), margin: Spacing.zero),
      ),
      // The font is the other half of that surface, and the one thing the model
      // leaves to the application: `BoxTextStyle.defaults` has no family, because
      // a font file is an asset. Flutter hands the tree the platform UI font by
      // saying nothing, so the document asks CSS for the same thing — a browser
      // falls back along the stack to the face its platform considers the UI font.
      // The stack is written raw because a comma separated list is a CSS
      // construct, while a `BoxTextStyle.fontFamily` names one family, which
      // Flutter and CSS both understand the same way.
      const StyleRule(
        selector: Selector('body'),
        styles: Styles(
          raw: <String, String>{
            'font-family':
                "system-ui, -apple-system, 'Segoe UI', Roboto, "
                'sans-serif',
          },
        ),
      ),
    ],
    body: ExampleApp(openSignup: page == ExamplePage.signup),
  );
}

/// The `<title>` of [page], which is what a search result links and what a
/// browser tab shows.
///
/// The page name comes first and the site name last, the order a reader scans a
/// result in.
String _titleOf(ExamplePage page) {
  return switch (page) {
    ExamplePage.signup => 'Join Unibox — sign up',
    ExamplePage.apartments => 'Apartments — Unibox',
  };
}

/// The `<meta name="description">` of [page].
///
/// It describes what the page is, in the words a reader would use, because a
/// search engine may show it under the title instead of an excerpt of the text.
String _descriptionOf(ExamplePage page) {
  return switch (page) {
    ExamplePage.signup =>
      'A sign-up card described as one Unibox node tree and rendered by '
          'Flutter and by Jaspr, with a working form on both.',
    ExamplePage.apartments =>
      'Six apartments with a map beside the listings on a wide screen and the '
          'listings alone on a narrow one, from the same node tree.',
  };
}
