import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

import 'theme.dart';

/// A listing on the apartments page.
///
/// Plain data, like the signup form: the page is a function of the list, so a
/// host can hand it what it loaded from wherever it loads things from without
/// touching the tree.
final class Apartment {
  /// Creates a listing.
  const Apartment({
    required this.name,
    required this.rooms,
    required this.area,
    required this.rent,
    required this.tint,
  });

  /// The name of the building.
  final String name;

  /// How many rooms it has.
  final int rooms;

  /// The living area in square metres.
  final int area;

  /// The monthly rent in euro.
  final int rent;

  /// The colour of the square standing in for its photo.
  final BoxColor tint;

  /// The one line summary under the name.
  String get summary => '$rooms rooms · $area m²';

  /// The asking rent.
  String get priceLine => '€$rent / month';
}

/// The listings the example shows.
///
/// More of them than fit on a normal window, which is the point: the page
/// scrolls under the navigation bar instead of growing the page.
const List<Apartment> exampleApartments = <Apartment>[
  Apartment(
    name: 'Via Bellavista 12',
    rooms: 3,
    area: 84,
    rent: 1850,
    tint: BoxColor(0xFFFDE8D3),
  ),
  Apartment(
    name: 'Corso Umberto 4',
    rooms: 2,
    area: 61,
    rent: 1240,
    tint: BoxColor(0xFFE1EBFA),
  ),
  Apartment(
    name: 'Piazza della Scala 7',
    rooms: 1,
    area: 44,
    rent: 980,
    tint: BoxColor(0xFFF3E3F1),
  ),
  Apartment(
    name: 'Vicolo del Forno 3',
    rooms: 4,
    area: 112,
    rent: 2400,
    tint: BoxColor(0xFFE3F2E8),
  ),
  Apartment(
    name: 'Lungomare 21',
    rooms: 2,
    area: 70,
    rent: 1420,
    tint: BoxColor(0xFFFAF0D5),
  ),
  Apartment(
    name: 'Salita San Marco 9',
    rooms: 3,
    area: 95,
    rent: 2100,
    tint: BoxColor(0xFFE8E6F7),
  ),
];

/// The apartments page: the listings, scrolling under the navigation bar.
///
/// The page scrolls, the frame does not. The scrolling box is the page itself
/// and the bar above it belongs to the frame, so the navigation stays where it
/// is while the list moves — on both targets, from `Overflow.scroll`, which is
/// a `SingleChildScrollView` in Flutter and `overflow: auto` in CSS.
///
/// The padding sits on a box *inside* the scrolling one on purpose: Flutter puts
/// the padding of a scrolling box around its viewport (so it stays put), while
/// CSS puts it inside the scrollport (so it scrolls away). Moving it one level
/// in leaves both renderers scrolling the same content.
Box buildApartmentsPage() {
  return Box(
    flex: 1,
    direction: Axis.vertical,
    width: double.infinity,
    overflow: Overflow.scroll,
    // The page is the `<main>` landmark; the scrolling box is the page itself.
    semantics: const BoxSemantics(element: BoxElement.main),
    children: <UINode>[
      Box(
        direction: Axis.vertical,
        width: double.infinity,
        padding: const BoxSpacing.all(24),
        gap: 20,
        textStyle: ExampleType.body,
        children: <UINode>[
          _heading(),
          // The cards reflow on their own: one column when the page is narrow,
          // two in the middle, three from 872 pixels on, with the width shared by
          // the tracks. The count comes from the model's arithmetic on the web as
          // well as in Flutter, so neither target needs a breakpoint.
          GridNode(
            minItemWidth: 280,
            maxColumns: 3,
            gap: 16,
            children: <UINode>[
              for (final Apartment apartment in exampleApartments)
                _card(apartment),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The title of the page and the line under it.
///
/// The title is marked as a heading, which is what a screen reader announces and
/// what a crawler uses to read the structure of the page: the web renderer writes
/// `role="heading"` and the Flutter one a `Semantics.header`. The line under it
/// stays plain text, because a heading is a label and not a paragraph.
UINode _heading() {
  return Box(
    direction: Axis.vertical,
    gap: 4,
    width: double.infinity,
    textStyle: ExampleType.title,
    children: <UINode>[
      const TextNode('Apartments', headingLevel: 1),
      TextNode(
        '${exampleApartments.length} listings in the old town.',
        style: ExampleType.muted,
      ),
    ],
  );
}

/// One listing: a Material card with a coloured square for the photo, then what
/// the rent gets you.
///
/// The card is a `MaterialCard` — a `Box` with Material's surface, radius,
/// elevation and body type — so the example shows the design system as well as the
/// model. Its width is the grid's track and its height is its content; the grid
/// top-aligns the cards of a row, so a shorter card does not stretch.
UINode _card(Apartment apartment) {
  return MaterialCard(
    semantics: const BoxSemantics(element: BoxElement.article),
    direction: Axis.vertical,
    gap: 10,
    children: <UINode>[
      Box(
        width: double.infinity,
        height: 140,
        borderRadius: 10,
        backgroundColor: apartment.tint,
      ),
      TextNode(
        apartment.name,
        style: MaterialTypography.titleMedium.merge(
          BoxTextStyle(color: MaterialPalette.light.onSurface),
        ),
      ),
      TextNode(
        apartment.summary,
        style: MaterialTypography.bodyMedium.merge(
          BoxTextStyle(color: MaterialPalette.light.onSurfaceVariant),
        ),
      ),
      TextNode(
        apartment.priceLine,
        style: MaterialTypography.labelLarge.merge(
          BoxTextStyle(color: MaterialPalette.light.primary),
        ),
      ),
    ],
  );
}
