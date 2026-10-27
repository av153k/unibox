# Changelog

## Unreleased

- `TextAppearance` describes the typography of a rendered text node, and
  `textCases` is the table both renderers are checked against: one case per token,
  one for the precedence of a `BoxTextStyle` and its flat overrides, and one with
  every token at once.
- `defaultTextAppearance` states the typography of a text that declares nothing,
  which both renderers have to produce, and a test keeps it in step with
  `core.BoxTextStyle.defaults`.
- `TokenDifference` is shared by both appearances.

## 0.1.0

The first release of the renderer contract.

- `BoxAppearance` describes the presentation of a rendered box: direction, main
  and cross alignment, gap, padding, margin, width, height, background colour,
  corner radius and border.
- `differencesFrom` compares two appearances token by token and names the ones
  that drifted, treating an absent token and a zero token as the same
  presentation.
- `boxCases` is the table both renderers are checked against: one case per
  token, plus one case with every token at once.
- The suite checks the table itself, so a case that stops pinning anything fails
  before a renderer gets the chance to pass it.
