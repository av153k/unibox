# Changelog

## Unreleased

- `TextNode.headingLevel` (1 to 6) makes a text a heading, and
  `BoxSemantics.element` gives a box an element: a landmark, sectioning content, or
  a list. Neither changes a look; both are what a page needs to be a document.
- `BoxSemantics` gains the accessibility state both platforms expose: `expanded`,
  `selected`, `hidden` and `liveRegion`. A hidden box is also no longer focusable,
  so it cannot be reached by keyboard either.
- `validateTree` reports a `BoxElement.li` whose parent is not a `ul` or an `ol`.
- `ImageFit.scaleDown` and `ImageNode.resolvedFit`: an image that names no fit is
  `scaleDown` rather than whatever its renderer falls back to. Flutter's `Image`
  already scaled down, while a browser stretched the picture over its box
  (`object-fit: fill`), so the same tree was squashed on one target and letterboxed
  on the other.
- The README lists the defaults of every node and what is deliberately left to the
  host.
- `BoxTextStyle.defaults` is the typography a text is typeset in when the tree
  says nothing else: 16 logical pixels, normal weight, black, a line height of 1.5
  and no letter spacing. Both renderers install it at the root of the tree they
  render, so an undeclared text no longer inherits whichever default its host
  happens to have. The font family stays unset, because a font file is an asset of
  the application.

## 0.1.0

The first release of the platform agnostic core.

- The node tree: `Box`, `TextNode`, `ImageNode`, `LinkNode`, `StackNode`,
  `PositionedNode` and `TextInputNode`, every node with an optional `key` that
  keeps state attached to its node when a list is reordered.
- Style tokens: `BoxStyle`, `BoxTextStyle`, `BoxColor`, `BoxSpacing`,
  `BoxBorder`, `BoxShadow`, plus the semantics tokens `BoxSemantics` and
  `BoxRole`.
- Layout defaults: `BoxStyle.resolvedDirection` resolves an unset `direction` to
  `Axis.vertical`, so a box is a flex container on every target and `gap`, the
  alignment tokens and a child's `flex` apply whether or not the direction is
  written out.
- Typography inheritance: `Box.textStyle` is inherited by the descendants, every
  other token applies to the box itself.
- Interaction states: `BoxState`, `Box.stateStyles`, `Box.enabled` and
  `Box.computedStyleFor`, with `hoverStyle` as sugar for the hover entry.
- Text input parity: `InputType`, `enabled`, `readOnly`, `autofocus`,
  `semanticsLabel` and `onFocusChanged`.
- `EmbedNode`, the escape hatch for host specific content.
- `validateTree`, which reports trees that no renderer can honour.
