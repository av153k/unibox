# Changelog

## Unreleased

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
