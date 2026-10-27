# Changelog

## Unreleased

- An `ImageNode` always emits `object-fit`, `scale-down` when the node names no
  fit: left out, a browser stretched the picture over its box while Flutter scaled
  it down.
- A stack child that is not positioned is placed with `place-self: start`, so it
  keeps its own size instead of stretching to fill the cell the way a grid item
  does by default.
- A text area starts at one row instead of the browser's two, and its styles carry
  `resize: none`, which removes the resize grip Flutter has no counterpart to.
- `renderJaspr` emits a `:root` rule carrying the typography of the model
  (`BoxTextStyle.defaults`), so a text that declares nothing is typeset at 16
  pixels, black, with a 1.5 line height and `font-family: system-ui` instead of the
  browser's own default — the same answer the Flutter renderer installs as a
  `DefaultTextStyle`. The tree it returns is therefore a fragment: the rule first,
  the tree second. `renderNode` renders a node without it.

## 0.1.0

The first release of the Jaspr (HTML/CSS) renderer.

- `renderJaspr` and `UINode.toComponent()` for every core node.
- Boxes map to flex containers with inline styles, and to scoped rules when they
  need `:hover` inside `@media (hover: hover)`, `:focus-visible`, `:active` or
  `[aria-disabled="true"]`.
- A box without a direction is a flex column, the same shape the Flutter
  renderer gives it, so `gap` and the alignment tokens apply to every box.
- Typography is inherited through the CSS font properties, which matches the
  `DefaultTextStyle` the Flutter renderer installs.
- Roles become `role`, `aria-label`, `aria-checked`, `aria-disabled` and
  `tabindex`, with Enter and Space activation.
- `TextInputNode` maps to an `<input>` or a `<textarea>` with its type, its
  autocomplete hint and its disabled, readonly and autofocus flags.
- A field keeps no browser form chrome: no border, no padding, no background, and
  no focus ring, and its font and colour are inherited from its box. A link
  cancels the user agent colour and underline. Both match what the Flutter
  renderer draws, so a field or a link looks the same on the two targets. The
  focus ring is dropped because a browser draws it around the field itself, which
  sits inside the padding and border of the box that wraps it: keeping it painted
  a second frame inside the one the tree asked for.
- A state rule only carries the tokens of its state, so `:hover`, `:focus-visible`
  and `:active` no longer restate the flex layout and a hovered row stays a row.
- `ComponentNode` embeds any Jaspr component.
- The tree is validated before it is rendered, so an invalid tree fails while it
  is being built instead of rendering something wrong.
