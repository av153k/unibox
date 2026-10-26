import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';

/// The document the example is served as.
///
/// The card centres itself in a page box that fills the viewport — `width` and
/// `height: double.infinity` render as `100%` — so the root elements have to
/// give that percentage something to resolve against. Without `height: 100%`
/// the page box collapses to the height of its content, which is a state a
/// Flutter host never gets into: a `Scaffold` body is as tall as the window, so
/// the card ends up in the middle of the screen there and at the top of a short
/// grey strip here.
///
/// The default body margin is removed for the same reason. Flutter lays the page
/// box out edge to edge, and the eight pixels a browser reserves around a body
/// would show up as a white frame around the canvas colour that nothing in the
/// node tree asked for.
///
/// Both rules describe the *host*, not the tree: they are the browser equivalent
/// of the surface a Flutter application is given, which is why they live next to
/// the app instead of in the renderer.
Document buildExampleDocument() {
  return Document(
    title: 'Unibox example',
    viewport: 'width=device-width, initial-scale=1',
    styles: <StyleRule>[
      StyleRule(
        selector: const Selector('html, body'),
        styles: Styles(height: const Unit.percent(100), margin: Spacing.zero),
      ),
      // The font is the other half of that surface. Flutter hands the tree the
      // platform UI font through its theme, so the document asks CSS for the same
      // thing: a browser falls back along the stack to the face its platform
      // considers the UI font. The stack is written raw because a comma separated
      // list is a CSS construct — a `BoxTextStyle.fontFamily` names one family,
      // which Flutter and CSS both understand the same way.
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
    body: const UniboxExampleApp(),
  );
}
