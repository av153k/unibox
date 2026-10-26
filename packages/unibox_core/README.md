# unibox_core

Platform agnostic Unibox AST, style tokens and layout types.

This package has zero external dependencies: it never imports `dart:ui`,
Flutter or Jaspr. Renderers live in `unibox_flutter` and `unibox_jaspr`.

## Nodes and tokens

| Type              | Purpose                                                      |
| ----------------- | ------------------------------------------------------------ |
| `Box`             | flex container, the primary building block                    |
| `TextNode`        | a run of text                                                 |
| `ImageNode`       | a network or bundled image                                    |
| `LinkNode`        | a link wrapping one child                                     |
| `StackNode`       | layered children, with `PositionedNode` placing them           |
| `TextInputNode`   | a single line or multiline field                              |
| `BoxColor`, `BoxSpacing`, `BoxBorder`, `BoxShadow` | visual tokens            |
| `BoxStyle`        | a bundle of every layout and visual token                     |
| `BoxTextStyle`    | a bundle of typography tokens                                 |

## Inheritance

`Box.textStyle` (or `BoxStyle.textStyle`) is inherited by the descendants of the
box; every other token only applies to the box itself. Typography is the single
inherited axis because it is the only one CSS and Flutter agree on: a box maps to
`DefaultTextStyle` in Flutter and to the inherited font properties in CSS.

A node resolves its own typography with `computedStyle`, which merges its flat
tokens over its `style`. `Box.computedTextStyle` does the same for a box, so both
renderers resolve identical values from identical input.

## Validation

`validateTree(node)` reports the trees no renderer can honour: a `PositionedNode`
outside a `StackNode`, a `LinkNode` nested in another `LinkNode`, and a scrolling
box that also distributes its children along the main axis. Both renderers run it
inside an assertion, so a broken tree fails while it is being built.
