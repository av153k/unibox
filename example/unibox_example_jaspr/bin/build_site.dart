import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:unibox_example_jaspr/document.dart';
import 'package:unibox_example_jaspr/site/site_page.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

/// Renders the site to static files: the Material gallery, the showcase and the
/// example it compares.
///
/// ```sh
/// dart run bin/build_site.dart --out=build/site
/// ```
///
/// The site is three kinds of document. The **gallery** is a node tree of the
/// Material package, the **showcase** is a node tree with two frames in it, and the
/// example is the app itself: `/web/` is the listings and `/web/signup/` is the same
/// page with the sign-up dialog open, because being open is state and a document
/// cannot be clicked into existence.
///
/// Nothing here decides a URL the build script does not also write: `tool/site.sh`
/// adds the Flutter build beside these files and the robots and sitemap that name
/// them.
Future<void> main(List<String> arguments) async {
  Jaspr.initializeApp();

  final Directory out = Directory(_option(arguments, 'out') ?? 'build/site');

  await _write(out, 'index.html', buildSiteDocument(page: SitePage.material));
  await _write(
    out,
    'showcase/index.html',
    buildSiteDocument(page: SitePage.showcase),
  );

  for (final ExamplePage page in ExamplePage.values) {
    final String path = page == ExamplePage.apartments
        ? 'web/index.html'
        : 'web/${page.name}/index.html';

    await _write(out, path, buildExampleDocument(page: page));
  }
}

/// Renders [document] to [path] below [out].
Future<void> _write(Directory out, String path, Document document) async {
  final ResponseLike rendered = await renderComponent(document);
  final File file = File('${out.path}/$path')..createSync(recursive: true);
  file.writeAsBytesSync(rendered.body);
  stdout.writeln('Wrote ${file.path} (${rendered.body.length} bytes)');
}

/// The value of `--name=value`, or `null` when the flag is absent.
String? _option(List<String> arguments, String name) {
  for (final String argument in arguments) {
    if (argument.startsWith('--$name=')) {
      return argument.substring(name.length + 3);
    }
  }
  return null;
}
