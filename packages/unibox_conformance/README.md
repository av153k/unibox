# unibox_conformance

The presentation contract both Unibox renderers are tested against.

The renderers produce different kinds of output — a widget tree on one side,
HTML and CSS on the other — so the only thing that can be compared is what the
output *does* with the same node. This package writes that down once:

- [`BoxAppearance`](lib/src/appearance.dart) describes how a box is presented:
  the axis it lays its children out on, its alignment, gap, padding, margin,
  size, background, corner radius and border.
- [`boxCases`](lib/src/cases.dart) is the table a renderer is checked against:
  one case per token, and one with every token at once.

The package holds the contract, not the tests. A renderer suite renders each
case, reads the appearance back from its own output and compares it with the
expected one:

```dart
for (final BoxCase boxCase in boxCases) {
  render(boxCase.box);

  expect(
    appearanceOf().differencesFrom(boxCase.expected),
    isEmpty,
    reason: boxCase.description,
  );
}
```

`unibox_flutter` reads the appearance out of the widgets its renderer built,
`unibox_jaspr` out of the CSS it emitted. Neither reads the node tree, so a
renderer that drops a token fails its own suite instead of drifting away from
the other one — and because both are checked against the same entry, the answer
cannot be relaxed for one target without failing the other.

What stays approximate on purpose is not part of the contract: the font face,
line breaking, shadow blur, placeholder and focus colours, and hit testing. A
browser and Flutter never agree on those down to the pixel.

## Testing

```shell
dart test
```

The suite checks the table itself: that the plain box is the first case, that
every other case changes its presentation, and that a comparison names the token
that drifted.

## License

MIT, like the rest of the workspace.
