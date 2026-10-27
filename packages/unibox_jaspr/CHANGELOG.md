# Changelog

## Unreleased

- A `StatefulNode` renders the state its store starts with: the tree, the overlays
  that first state asks for, and no `onMount` call, so a server render never starts
  the work a page starts when it appears. Reacting to an event needs the client
  runtime that is still on the plan.
- A box with `BoxElement.figcaption` renders `<figcaption>`, with no role repeating
  what the tag says.
- A field writes `aria-required`, `aria-invalid` and `aria-description`, the last one
  carrying the text itself rather than pointing at an element by id.
- A box with `BoxSemantics.current` writes `aria-current` with the kind of current
  it is.
- A transition with parts writes one `transition` entry per look, each with its own
  duration, curve and `transition-delay`, in paint-first order.
- `opacity` is written as the property of the same name and `transform` as
  `translate(x, y) rotate(deg) scale(s)` with no `transform-origin`, because CSS
  centres a transform by default. Both are part of the `transition` shorthand, so a
  state that introduces one is interpolated by the browser.
- A box with a transition writes a `transition` shorthand over the paint
  properties it animates, on the resting rule only, so a browser interpolates the
  change of a state rule without any script.
- An embed is dispatched by payload type instead of by node class: a `Component` is
  rendered as it is and a `ComponentEmbedBuilder` receives the rendered child, so a
  node class from outside this package renders here. Two drawable payloads, none,
  and a builder without a child are all reported with the types this target
  accepts.
- `ComponentEmbedBuilder` is exported, and `ComponentNode` carries its component as
  its implementation.
- A heading renders `<h1>`–`<h6>`, with the user agent's margin, size and weight
  cancelled so the tree keeps deciding how a heading looks.
- A box renders the element it names — `main`, `nav`, `header`, `footer`, `aside`,
  `section`, `article`, `form`, `figure`, `ul`, `ol`, `li` — instead of a `<div>`,
  with the space a list or a figure brings cancelled, and `role` only written when
  the element does not already imply it.
- `expanded`, `selected`, `hidden` and `liveRegion` become `aria-expanded`,
  `aria-selected`, `aria-hidden` and `aria-live`; a hidden box loses its `tabindex`.
- An `ImageNode` always emits `object-fit`, `scale-down` when the node names no
  fit: left out, a browser stretched the picture over its box while Flutter scaled
  it down.
- A stack child that is not positioned is laid out at the start of both axes by
  its cell wrapper, so it keeps its own size instead of stretching to fill the
  cell the way a grid item does by default. The wrapper still fills the cell, which
  is what lets a child with `width: double.infinity` resolve its `100%`.
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
