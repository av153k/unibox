# Changelog

## 0.1.0

The first release: Material 3 as a package of values, plus the components built
from them. Every value here is a plain token of `unibox_core`, so neither renderer
has to know this package exists.

- `MaterialTypography`: the fifteen roles of the Material 3 type scale as `const`
  `BoxTextStyle` values, with `MaterialTypeRole` to name one in a table or a test and
  `MaterialTypography.of` to look one up.
- `MaterialCard`: a card as a node that extends `Box` — 16 of padding, a white
  surface, a 12 pixel radius, the shade of elevation level one and `bodyMedium` for
  the texts inside, every one of them a parameter.
- `MaterialListTile`: the list row — a leading node, a title with an optional
  subtitle and a trailing node, 16 between its parts, the one and two line heights
  Material gives a tile (and their dense pair), `bodyLarge` for the title,
  `bodyMedium` in `onSurfaceVariant` for the subtitle, the 8% and 12% hover and press
  layers, and the button role when the tile can be tapped.

Material's colour scheme, its tonal surfaces and a ripple are not in this release:
the values a scheme would carry are documented constants until a palette exists.
