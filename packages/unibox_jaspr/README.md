# unibox_jaspr

Jaspr renderer for [Unibox](../unibox_core) layout primitives.

```dart
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_jaspr/unibox_jaspr.dart';

const card = Box(
  width: double.infinity,
  padding: BoxSpacing.all(16),
  backgroundColor: BoxColor.white,
  borderRadius: 12,
  children: [TextNode('Hello')],
);

void main() {
  runApp(renderJaspr(card)); // or, equivalently: card.toComponent()
}
```

Nodes without a web renderer yet throw an `UnsupportedError` instead of silently
rendering nothing.

## Box mapping

| Unibox                        | Jaspr / CSS                                            |
| ----------------------------- | ------------------------------------------------------ |
| always                        | `<div>` with `box-sizing: border-box`                  |
| `direction: Axis.horizontal`  | `display: flex` + `flex-direction: row`                |
| `direction: Axis.vertical`    | `display: flex` + `flex-direction: column`             |
| no `direction`                | plain block `<div>`                                    |
| `mainAlign` / `crossAlign`    | `justify-content` / `align-items` (`start` by default)  |
| `gap`                         | `gap`                                                  |
| `width`, `height`, `min*`, `max*` | `width`, `height`, `min-width`, ...                |
| `padding` / `margin`          | `padding` / `margin` shorthands                        |
| `backgroundColor`             | `background-color`                                     |
| `borderRadius`                | `border-radius`                                        |
| `border`                      | `border` (`none` when the width is zero)               |
| `shadow`                      | `box-shadow`                                           |
| `overflow`                    | `overflow` (`scroll` → `auto`)                         |
| `flex`                        | `flex-grow` / `flex-shrink: 1` / `flex-basis: 0`        |
| `onTap` / `onLongPress`       | `click` and pointer listeners plus `cursor: pointer`    |
| `onHover`                     | `mouseenter` / `mouseleave` listeners                   |
| `hoverStyle`                  | scoped `.unibox-box-…` and `.unibox-box-…:hover` rules  |

`width`/`height: double.infinity` becomes `100%`, numbers become logical pixels
(`px`). Tokens that are left unset emit no CSS property at all, so browser
defaults and inherited typography keep applying — the same rule the Flutter
renderer follows with `DefaultTextStyle`.

Opaque colors render as `#rrggbb`, translucent colors as `rgba(…)`.

### Hover styles

Inline styles always beat a `:hover` pseudo class, so a box with a `hoverStyle`
is rendered as a class plus a small `<style>` element right before it:

```html
<style>
  .unibox-box-1f3c9a7b { … }
  .unibox-box-1f3c9a7b:hover { … }
</style>
<div class="unibox-box-1f3c9a7b">…</div>
```

The class name is a hash of the resolved styles, which keeps the output
deterministic: server rendered markup and the hydrated client agree without any
extra state, and boxes that share a style share a class.

### Interaction

A box without callbacks renders no listeners, so static pages ship no
JavaScript for it. A tappable box also gets `cursor: pointer`. Long presses map
to pointer listeners with a 500 ms threshold and suppress the follow-up `click`,
mirroring Flutter.

## Testing

```sh
dart test
```

Component tests use `jaspr_test`; `test/support/harness.dart` exposes
`pumpNode`, `stylesOf`, `classesOf` and `cssOf` helpers to assert on the
rendered DOM.
