import 'package:flutter/material.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

void main() => runApp(ExampleApp(signupOpen: signupOpenFromUrl()));

/// Whether the sign-up dialog starts open, read from the path the page is served at.
///
/// A static host cannot boot a page with a click, so the export writes one document
/// per destination — `/flutter/showcase/` and `/flutter/showcase/signup/` — and the
/// app reads which one it was served as. Any other path, and every build that is not
/// a static export, starts with the dialog closed.
bool signupOpenFromUrl() => Uri.base.pathSegments.contains('signup');

/// The Flutter host of the shared page.
///
/// The page is one node — [ExamplePageNode] — so this file is only what a node
/// cannot know: the surface the tree is drawn on, what following a link means,
/// and whether the window is wide enough for the map.
///
/// The map is the one layout question a node cannot ask, because a box cannot
/// know how wide the surface is. `ExampleLayout.wideBreakpoint` is the number
/// both hosts share: Flutter compares the window with it here, the web host turns
/// it into a media query, and both end up with one column of listings on a narrow
/// surface.
class ExampleApp extends StatelessWidget {
  /// Creates the example application.
  ///
  /// [signupOpen] is for the static site, where a document starts in the state the
  /// destination names instead of waiting for a click.
  const ExampleApp({super.key, this.signupOpen = false});

  /// Whether the sign-up dialog is open on the first frame.
  final bool signupOpen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unibox example',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FlutterLinkScope(
          open: (String url) => debugPrint('Following $url'),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return FlutterStateful(
                node: ExamplePageNode(
                  signupOpen: signupOpen,
                  panel: constraints.maxWidth >= ExampleLayout.wideBreakpoint
                      ? buildExampleMap()
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
