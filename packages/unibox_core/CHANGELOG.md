# Changelog

## 0.1.0

The first release of the platform agnostic core.

- The node tree: `Box`, `TextNode`, `ImageNode`, `LinkNode`, `StackNode`,
  `PositionedNode` and `TextInputNode`, every node with an optional `key` that
  keeps state attached to its node when a list is reordered.
- Style tokens: `BoxStyle`, `BoxTextStyle`, `BoxColor`, `BoxSpacing`,
  `BoxBorder`, `BoxShadow`, plus the semantics tokens `BoxSemantics` and
  `BoxRole`.
- Typography inheritance: `Box.textStyle` is inherited by the descendants, every
  other token applies to the box itself.
- Interaction states: `BoxState`, `Box.stateStyles`, `Box.enabled` and
  `Box.computedStyleFor`, with `hoverStyle` as sugar for the hover entry.
- Text input parity: `InputType`, `enabled`, `readOnly`, `autofocus`,
  `semanticsLabel` and `onFocusChanged`.
- `EmbedNode`, the escape hatch for host specific content.
- `validateTree`, which reports trees that no renderer can honour.
