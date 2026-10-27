# Changelog

## 0.1.0

The first release of the Jaspr renderer: one node tree becomes HTML and CSS, rendered
on the server and readable without a client bundle.

- `JasprGrid` writes a `GridNode` as one `repeat(auto-fill, minmax(…))`
  declaration with the clamped minimum and the derived cap, so a build sends no
  media query and a resize sends no request.
- `renderJaspr(node)` and `node.toComponent()` render any node, and `renderNode` the
  same without re-validating a subtree that was already checked.
- A box is one element with `display: flex` and its tokens as CSS: direction,
  distribution, alignment, gap, `flex`, size, bounds, padding, margin, background,
  radius, border, shadow, opacity and transform.
- An element says what a box is: `main`, `nav`, `header`, `footer`, `aside`,
  `section`, `article`, `form`, `figure`, `figcaption`, `ul`, `ol` and `li`, with the
  space the user agent adds cancelled and a `role` written only when the tag does not
  already imply it.
- Typography becomes the inherited CSS font properties, and `renderJaspr` emits the
  model's default typography in a `:root` rule so an undeclared text is typeset the
  same way the Flutter renderer typesets it.
- A colour role is written as `var(--unibox-color-<name>)` and the theme as one
  `:root` block — every role, whether or not a node names it — so a host stylesheet,
  a `prefers-color-scheme: dark` block or an embed can outrank the tree without
  touching it. `renderJaspr` takes the theme; a host composing the components itself
  installs `JasprThemeScope`.
- Every look is written once, as a class rule in a single `<style>` element, and the
  element carries the class instead of an inline style: the CSS grows with the number
  of distinct looks on a page rather than with the number of elements, and a host can
  override any of it with a stylesheet or a custom property. A state-styled element
  used to carry its own `<style>`, so identical cards repeated their rules once each.
- An `ImageNode` becomes an `<img>` with everything a browser can use: `srcset`,
  `sizes`, `loading` and `fetchpriority`, and a finite `width`/`height` written both
  as CSS and as the element's attributes, so the browser reserves the right box
  before the picture arrives.
- A `BoxTransition` becomes one `transition` entry per property, with
  `transition-delay` where a part asks for one, so a state change is interpolated by
  the browser and a static export animates with no JavaScript.
- State styles become scoped rules: `:hover` inside `@media (hover: hover)`,
  `:focus-visible`, `:active` and `[aria-disabled="true"]`, each carrying only the
  tokens of its state.
- Semantics become attributes: `role`, `aria-label`, `aria-checked`, `aria-expanded`,
  `aria-selected`, `aria-hidden`, `aria-live`, `aria-current`, `tabindex` and the
  form field's `aria-required`, `aria-invalid` and `aria-description`.
- A `TextInputNode` is an `<input>` or a `<textarea>` with the browser's chrome
  removed, so it looks like the field the tree describes.
- `JasprStateful` drives a `StatefulNode` in a browser and only reads its store on the
  server, and `JasprComponentNode` embeds any component.
