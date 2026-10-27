# unibox_conformance

The presentation contract both Unibox renderers are tested against.

The renderers produce different kinds of output — a widget tree on one side,
HTML and CSS on the other — so the only thing that can be compared is what the
output *does* with the same node. This package writes that down once:

- [`BoxAppearance`](lib/src/appearance.dart) describes how a box is presented:
  the axis it lays its children out on, its alignment, gap, padding, margin,
  size, background, corner radius and border.
- [`boxCases`](lib/src/cases.dart) is the box table a renderer is checked
  against: one case per token, and one with every token at once.
- [`TextAppearance`](lib/src/text_appearance.dart) describes how a text node is
  typeset: font size, weight, colour, line height, letter spacing, family,
  alignment and truncation.
- [`textCases`](lib/src/text_cases.dart) is the text table: one case per token,
  one for the precedence of a `BoxTextStyle` and its flat overrides, and one with
  every token at once.

The package holds the contract, not the tests. A renderer suite renders each
case, reads the appearance back from its own output and compares it with the
expected one:

```dart
for (final TextCase textCase in textCases) {
  render(textCase.node);

  expect(
    textAppearanceOf().differencesFrom(textCase.expected),
    isEmpty,
    reason: textCase.description,
  );
}
```

`unibox_flutter` reads the appearance out of the widgets its renderer built,
`unibox_jaspr` out of the CSS it emitted. Neither reads the node tree, so a
renderer that drops a token fails its own suite instead of drifting away from
the other one — and because both are checked against the same entry, the answer
cannot be relaxed for one target without failing the other.

## How close is close

Passing both tables means the two renderers ask their host to draw the same
thing. It does not mean the hosts draw the same pixels, and nothing here claims
it does. The line runs between what a renderer *declares* and what a text engine
*makes of it*:

| Same                                                              | Why |
| ----------------------------------------------------------------- | --- |
| the tokens a node declares                                        | one table, read back from each output |
| the height of a line box                                          | `fontSize * lineHeight` on both: CSS multiplies the unitless `line-height`, `TextStyle.height` does the same |
| the layout of the boxes                                           | flexbox on one side, `Flex`/`Row`/`Column` on the other, with the same rules |
| the glyphs                                                        | **no**: Skia and the browser each rasterise text with their own engine |
| where a line wraps                                                | **no**: two engines measure the same string differently, so the break can fall elsewhere |
| a font that the app ships to both hosts                           | only then; a family installed on one side only falls back, and the fallback changes the metrics |
| the typography nobody declared                                    | only if the tree declares it: Flutter falls back to 14 logical pixels of black, a browser to 16 pixels of `canvastext` |

Which is why a tree that has to be pixel-stable declares its typography and its
`lineHeight`, and ships the same font file to both hosts. Set the two, and
everything above the glyphs is identical; leave them out, and the host decides.

What stays approximate on purpose, and is therefore outside the contract
altogether: the font face, line breaking, shadow blur, placeholder and focus
colours, and hit testing.

One combination inside the model has no exact counterpart, which is why it is not
in the table: `maxLines` with `TextOverflow.clip`. Flutter cuts the text off after
the last line; a `-webkit-line-clamp` box always ends it with an ellipsis, and
`text-overflow: clip` does not take the ellipsis away (checked in Chrome, not
assumed). An application that needs the two to agree uses `maxLines` with
`TextOverflow.ellipsis`.

## Testing

```shell
dart test
```

The suite checks the tables themselves: that the plain box and the plain text are
the first cases, that every other case changes its presentation, that every token
of a node appears in the "every token at once" case, and that a comparison names
the token that drifted.

## License

MIT, like the rest of the workspace.
