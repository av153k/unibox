import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

import 'support/tree.dart';

/// The box that holds the listings, the one that declares the `flex` factor.
Box listingsColumn(UINode page) =>
    flatten(page).whereType<Box>().firstWhere((Box box) => box.flex == 3);

void main() {
  group('Apartment', () {
    test('summarises itself for the card', () {
      const Apartment apartment = Apartment(
        name: 'Via Bellavista 12',
        rooms: 3,
        area: 84,
        rent: 1850,
        tint: BoxColor.black,
      );

      expect(apartment.summary, '3 rooms · 84 m²');
      expect(apartment.priceLine, '€1850 / month');
    });

    test('gives every listing in the example its own name', () {
      final Set<String> names = exampleApartments
          .map((Apartment apartment) => apartment.name)
          .toSet();

      expect(exampleApartments.length, greaterThan(4));
      expect(names, hasLength(exampleApartments.length));
    });
  });

  group('buildApartmentsPage', () {
    test('scrolls instead of growing the page', () {
      final Box page = buildApartmentsPage();

      expect(page.overflow, Overflow.scroll);
      expect(page.flex, 1);
      expect(page.direction, Axis.vertical);
      // A scrolling box may not distribute its children: they would be pushed
      // out of reach instead of scrolled to.
      expect(page.mainAlign, isNull);
    });

    test('keeps the padding inside the scrolling area', () {
      // Flutter puts the padding of a scrolling box around its viewport, CSS puts
      // it inside the scrollport, so the padding of the page sits one level in.
      final Box page = buildApartmentsPage();

      expect(page.padding, isNull);
      expect(page.children.single, isA<Box>());
      expect((page.children.single as Box).padding, isNotNull);
    });

    test('lists every apartment of the example', () {
      final List<String> texts = textsIn(buildApartmentsPage());

      expect(texts.first, 'Apartments');
      for (final Apartment apartment in exampleApartments) {
        expect(texts, contains(apartment.name));
        expect(texts, contains(apartment.summary));
        expect(texts, contains(apartment.priceLine));
      }
    });

    test('leaves the map out when the host has no room for it', () {
      expect(textsIn(buildApartmentsPage()), isNot(contains('Map')));
    });

    test('puts the map in the second column of the row', () {
      final Box map = buildExampleMap();
      final Box page = buildApartmentsPage(map: map);

      // The panel is a child of the row itself, so a host that hides it hides the
      // whole column instead of leaving an empty one behind.
      final Box row = flatten(page)
          .whereType<Box>()
          .firstWhere((Box box) => box.children.contains(map));

      expect(row.direction, Axis.horizontal);
      expect(map.flex, 2);
    });

    test('keeps the listings in the wider column', () {
      final Box page = buildApartmentsPage(map: buildExampleMap());

      expect(listingsColumn(page).flex, 3);
      expect(textsIn(listingsColumn(page)), contains('Via Bellavista 12'));
      expect(textsIn(listingsColumn(page)), isNot(contains('Map')));
    });

    test('highlights a listing under the pointer', () {
      final Box listing = flatten(buildApartmentsPage())
          .whereType<Box>()
          .firstWhere((Box box) => box.stateStyle(BoxState.hover) != null);

      expect(textsIn(listing), contains('Via Bellavista 12'));
      expect(
        listing.stateStyle(BoxState.hover)?.border?.color,
        ExamplePalette.accent,
      );
    });
  });

  group('buildExampleMap', () {
    test('is a filled square with a label', () {
      final Box map = buildExampleMap();

      expect(map.width, double.infinity);
      expect(map.height, 420);
      expect(map.backgroundColor, ExamplePalette.mapSurface);
      expect(textsIn(map), <String>['Map']);
    });
  });
}
