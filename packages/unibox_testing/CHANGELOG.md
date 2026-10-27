# Changelog

## Unreleased

- A box case for the merge order of `Box.styles`, so both renderers are held to the
  same left-to-right result.
- `BoxAppearance` carries `opacity` and `transform`, with cases for both and both
  tokens added to the "every token at once" case. The Flutter suite reads the
  transform back out of the matrix the renderer composed; the web suite parses the
  declaration. An identity transform compares as no transform.
- `BoxAppearance` carries `transitionDuration` and `transitionCurve`, and the box
  table gains a case for them: both renderers have to state the same duration and
  the same curve for the same transition.
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
