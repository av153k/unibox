# Changelog

## Unreleased

- `renderFlutter` wraps the rendered tree in the typography of the model
  (`BoxTextStyle.defaults`) through a `DefaultTextStyle`, so a text that declares
  nothing is typeset at 16 logical pixels, black, with a 1.5 line height instead of
  Flutter's own fallback of 14 pixels. The style is merged over the ambient one, so
  a host keeps its font family, and a box in the tree overrides any token.
- A `TextInputNode` adopts the typography of the tree in every tree now, because
  there is always one to adopt: it used to keep the Material input style when no
  box declared typography.

## 0.1.0

The first release of the Flutter renderer.

- `renderFlutter` and `UINode.toWidget()` for every core node.
- Boxes map to `Row`, `Column`, `Stack`, `Padding`, `DecoratedBox`,
  `ClipRect`, `SingleChildScrollView`, `GestureDetector` and `MouseRegion`.
- A box without a direction maps to a `Column`, the same as `Axis.vertical`, so
  `gap`, `mainAlign`, `crossAlign` and a child's `flex` apply to every box.
- Typography is inherited through `DefaultTextStyle`; a `TextInputNode` opts in
  through `UniboxTextStyleScope`, so a field follows the box that owns it.
- Interaction states: hover, focus, press and disabled, with `Focus` and
  keyboard activation on Enter and Space, plus `Semantics` roles, labels and the
  enabled flag.
- `TextInputNode` maps to a `TextField` with the keyboard, the autofill hints
  and the enabled, read only and autofocus flags of the node.
- A field renders without Material's decoration: no underline, no content
  padding and no 48 pixel minimum height, so it occupies exactly its line box.
  That is what a plain `<input>` does on the web, and it lets the box around a
  field be the only thing that draws one.
- A box renders its flex container even when it has no children, so an empty box
  describes the same shape here as the flex container the web renderer emits.
- `UniboxBox`, `UniboxText`, `UniboxTextInput`, `UniboxLink`, `UniboxImage` and
  `UniboxStack` are exported, so a host or a test can address a rendered node
  without depending on its position in the tree.
- `WidgetNode` embeds any Flutter widget.
- Links follow their url through `UniboxLinkScope`; a link that can neither open
  nor call back is reported as a host configuration error in debug builds.
- The tree is validated before it is rendered, so an invalid tree fails while it
  is being built instead of rendering something wrong.
