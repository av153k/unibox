import 'package:flutter/material.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

void main() => runApp(const ExampleApp());

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
  const ExampleApp({super.key});

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
