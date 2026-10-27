# Changelog

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
