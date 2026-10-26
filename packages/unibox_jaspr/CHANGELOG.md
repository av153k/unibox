# Changelog

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
- `ComponentNode` embeds any Jaspr component.
- The tree is validated before it is rendered, so an invalid tree fails while it
  is being built instead of rendering something wrong.
