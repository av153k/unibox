# Changelog

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
- `WidgetNode` embeds any Flutter widget.
- Links follow their url through `UniboxLinkScope`; a link that can neither open
  nor call back is reported as a host configuration error in debug builds.
- The tree is validated before it is rendered, so an invalid tree fails while it
  is being built instead of rendering something wrong.
