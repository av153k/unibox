import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_example_jaspr/document.dart';

/// Renders the example to one static HTML file per page.
///
/// The Unibox renderer emits plain elements, inline styles and scoped `<style>`
/// rules, so the page needs no client bundle to be readable: run
///
/// ```sh
/// dart run unibox_example_jaspr:build
/// ```
///
/// and open `build/index.html`. Navigation is host state, which a static export
/// cannot keep, so every page is written on its own — `build/apartments.html` is
/// the second page, and resizing the window there is what the breakpoint does:
/// the map is beside the listings on a wide window and gone on a narrow one,
/// with no JavaScript involved.
Future<void> main() async {
  Jaspr.initializeApp();

  for (final ExamplePage page in ExamplePage.values) {
    final ResponseLike rendered = await renderComponent(
      buildExampleDocument(page: page),
    );

    final File file = File('build/${_fileNameOf(page)}')
      ..createSync(recursive: true)
      ..writeAsBytesSync(rendered.body);

    stdout.writeln('Wrote ${file.path} (${rendered.body.length} bytes)');
  }
}

/// The file the static export writes [page] to.
String _fileNameOf(ExamplePage page) {
  return page == ExamplePage.signup ? 'index.html' : '${page.name}.html';
}
