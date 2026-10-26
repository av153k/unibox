import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:unibox_example_jaspr/app.dart';

/// Renders the example to a static HTML file.
///
/// The Unibox renderer emits plain elements, inline styles and scoped `<style>`
/// rules, so the page needs no client bundle to be readable: run
///
/// ```sh
/// dart run unibox_example_jaspr:build
/// ```
///
/// and open `build/index.html`.
Future<void> main() async {
  Jaspr.initializeApp();

  final ResponseLike page = await renderComponent(const UniboxExampleApp());

  final File file = File('build/index.html')
    ..createSync(recursive: true)
    ..writeAsBytesSync(page.body);

  stdout.writeln('Wrote ${file.path} (${page.body.length} bytes)');
}
