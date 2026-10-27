import 'dart:convert';

import 'package:jaspr/server.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_example_jaspr/document.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

void main() {
  setUpAll(Jaspr.initializeApp);

  group('buildExampleDocument', () {
    late String html;

    setUpAll(() async {
      final ResponseLike page = await renderComponent(buildExampleDocument());
      html = utf8.decode(page.body);
    });

    test('gives the page box a height to fill', () {
      // The card centres itself in a box that fills the page (`height: 100%`).
      // A percentage only resolves against a parent with a height, so the root
      // elements have to supply one: without it the page box collapses to the
      // height of the card, which is a state a Flutter host never gets into.
      expect(html, contains('html, body {'));
      expect(html, contains('height: 100%;'));
    });

    test('removes the default body margin', () {
      // Flutter lays the page box out edge to edge, so the eight pixels a
      // browser reserves around a body would show up as a frame nothing in the
      // node tree asked for.
      expect(html, contains('margin: 0;'));
    });

    test('asks for the platform UI font', () {
      // Flutter hands the tree the platform font through its theme; the stack is
      // the CSS way of asking for the same face.
      expect(html, contains('font-family: system-ui'));
      expect(html, contains('sans-serif'));
    });

    test('renders the shared card', () {
      expect(html, contains('Unibox example'));
      expect(html, contains('Join Unibox'));
    });

    test('writes the apartments page on request', () async {
      // Navigation is state, so a static export cannot switch pages by itself:
      // the second page is written next to the first one, and the breakpoint is
      // the only thing that has to work without a client bundle.
      final ResponseLike page = await renderComponent(
        buildExampleDocument(page: ExamplePage.apartments),
      );
      final String apartments = utf8.decode(page.body);

      expect(apartments, contains('Via Bellavista 12'));
      expect(apartments, contains('overflow: auto'));
      expect(apartments, contains('@media screen and (min-width: 900px)'));
      expect(apartments, contains('display: none;'));
    });
  });
}
