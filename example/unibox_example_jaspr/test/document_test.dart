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
      final ResponseLike page = await renderComponent(
        buildExampleDocument(page: ExamplePage.signup),
      );
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
      expect(html, contains('Join Unibox'));
      expect(html, contains('One description, two renderers.'));
    });

    test('starts with the sign-up dialog over the listings', () {
      // Being open is state, and a static document has nothing to click: the
      // sign-up document is rendered with the dialog already in the tree, over
      // the page it belongs to.
      expect(html, contains('role="dialog"'));
      expect(html, contains('aria-modal="true"'));
      expect(html, contains('Via Bellavista 12'));
    });

    test('declares the language of the page', () {
      // A crawler and a screen reader both guess the language when the document
      // does not state it.
      expect(html, contains('<html lang="en">'));
    });

    test('describes the page to a search engine', () {
      expect(html, contains('<title>Join Unibox — sign up</title>'));
      expect(
        html,
        contains('<meta name="description" content="A sign-up card'),
      );
    });

    test('marks the page title as a heading', () {
      // A heading is an element here, so a crawler reads the outline of the page
      // and a screen reader announces the level.
      expect(html, contains('<h1 '));
      expect(html, contains('Join Unibox'));
    });

    test('writes the listings as the entry document', () async {
      // The form is reached from the bar, so the document that opens the site is
      // the page it belongs to: a browser without the client bundle cannot
      // dismiss a dialog.
      final ResponseLike page = await renderComponent(buildExampleDocument());
      final String listings = utf8.decode(page.body);

      expect(listings, contains('<title>Apartments — Unibox</title>'));
      expect(listings, contains('Via Bellavista 12'));
      expect(listings, isNot(contains('Join Unibox')));
      expect(listings, isNot(contains('role="dialog"')));
    });

    test('writes the apartments page on request', () async {
      // Navigation is state, so a static export cannot switch pages by itself:
      // the listing document is written next to the sign-up one.
      final ResponseLike page = await renderComponent(
        buildExampleDocument(page: ExamplePage.apartments),
      );
      final String apartments = utf8.decode(page.body);

      expect(apartments, contains('Via Bellavista 12'));
      expect(apartments, contains('overflow: auto'));
      expect(apartments, isNot(contains('role="dialog"')));
    });

    test('gives the apartments page its own title and description', () async {
      // Two documents that share a title read as one page twice, and a result
      // that repeats the sign-up copy under the apartments listing is worse than
      // no description at all.
      final ResponseLike page = await renderComponent(
        buildExampleDocument(page: ExamplePage.apartments),
      );
      final String apartments = utf8.decode(page.body);

      expect(apartments, contains('<title>Apartments — Unibox</title>'));
      expect(apartments, contains('Six apartments'));
      expect(
        apartments,
        isNot(contains('<title>Join Unibox — sign up</title>')),
      );
    });
  });
}
