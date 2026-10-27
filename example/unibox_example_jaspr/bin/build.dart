import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_example_jaspr/main.dart';

/// Renders the example to one static HTML file per page, plus a `robots.txt`.
///
/// The Unibox renderer emits plain elements, inline styles and scoped `<style>`
/// rules, so the page needs no client bundle to be readable: run
///
/// ```sh
/// dart run unibox_example_jaspr:build
/// ```
///
/// and open `build/index.html`. Being open is host state, which a static export
/// cannot keep, so every destination is written on its own — `index.html` is the
/// listings, `build/signup.html` is the same page with the sign-up dialog over it
/// — and resizing the window is what the breakpoint does: the map is beside the
/// listings on a wide window and gone on a narrow one, with no JavaScript
/// involved.
///
/// What a crawler can read is the export itself: the text, the `<img alt>` texts,
/// the real `<a href>` of a `LinkNode`, the `role` attributes of the semantics
/// tokens, and the `<title>`, description and `lang` of each page. A sitemap is
/// the one thing that cannot be written here — it needs the url the pages are
/// served from, which only the deployment knows — so the file names it lists are
/// the two this loop writes.
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

  File('build/robots.txt')
    ..createSync(recursive: true)
    ..writeAsStringSync('User-agent: *\nAllow: /\n');
  stdout.writeln('Wrote build/robots.txt');
}

/// The file the static export writes [page] to.
String _fileNameOf(ExamplePage page) {
  return page == ExamplePage.apartments ? 'index.html' : '${page.name}.html';
}
