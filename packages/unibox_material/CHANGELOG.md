# Changelog

## Unreleased

- `MaterialListTile`: the Material 3 list tile as a node. A row that fills its
  width, 16 logical pixels between its parts and 16 of side padding, the one and two
  line heights Material gives a tile (and their dense variants), `bodyLarge` for the
  title and `bodyMedium` in `onSurfaceVariant` for the subtitle, black at 8% and 12%
  for the hover and press layers, and the button role when the tile can be tapped.
  Every token is a parameter, and the colours a scheme would carry are documented
  constants until one exists.
- `MaterialCard`: the Material 3 card as a node. It extends `Box`, so it is drawn by
  the renderer each target already has and every token it sets is already in the
  conformance table: 16 logical pixels of padding, a `BoxColors.white` surface, a
  12 pixel radius, `elevatedShadow` (elevation level one, expressed as the one
  `BoxShadow` the model has) and `MaterialTypography.bodyMedium` for the texts
  inside. Every token is a parameter, the layout and interaction of a box come
  through, and a colour scheme, the tonal variants and a ripple are not pretended
  to exist.
- The renderer suites pin the property the card rests on: a node that extends `Box`
  renders as that box on both targets, without either renderer knowing the node's
  class.
- The first release of the package: the Material Design 3 type scale as
  `BoxTextStyle` values.
- `MaterialTypography` states the fifteen roles of the scale (`displayLarge` to
  `labelSmall`) with their size, weight, letter spacing and line height, taken
  from the Material 3 specification (the same scale Flutter ships as
  `Typography.englishLike2021`). Every role is a complete style, so it resets the
  tokens it does not share instead of inheriting them; `color` and `fontFamily`
  stay unset because they belong to the theme.
- `MaterialTypography.styles` is the whole scale keyed by `MaterialTypeRole` in
  scale order, and `MaterialTypography.of` looks a role up.
- `MaterialTypeRole` names the fifteen roles, declared from the largest text to
  the smallest.
- The package does not depend on Flutter, `dart:ui` or Material: it builds on
  `unibox_core` alone, so both renderers and any other consumer of the tree get
  the same typography.
