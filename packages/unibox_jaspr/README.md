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
| no `direction`                | `display: flex` + `flex-direction: column`, as above   |
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
| `stateStyles`                 | scoped `.unibox-box-…` rules, one per state             |

`width`/`height: double.infinity` becomes `100%`, numbers become logical pixels
(`px`). Tokens that are left unset emit no CSS property at all, so browser
defaults and inherited typography keep applying — the same rule the Flutter
renderer follows with `DefaultTextStyle`.

Opaque colors render as `#rrggbb`, translucent colors as `rgba(…)`.

### State styles

Inline styles always beat a pseudo class, so a box with state styles is rendered
as a class plus a small `<style>` element right before it:

```html
<style>
  .unibox-box-1f3c9a7b { … }
  @media all and (hover: hover) {
    .unibox-box-1f3c9a7b:hover { … }
  }
  .unibox-box-1f3c9a7b:focus-visible { … }
  .unibox-box-1f3c9a7b:active { … }
  .unibox-box-1f3c9a7b[aria-disabled="true"] { … }
</style>
<div class="unibox-box-1f3c9a7b">…</div>
```

| Unibox state        | CSS selector                                    |
| ------------------- | ----------------------------------------------- |
| `BoxState.hover`    | `:hover` inside `@media (hover: hover)`          |
| `BoxState.focus`    | `:focus-visible`                                |
| `BoxState.pressed`  | `:active`                                       |
| `BoxState.disabled` | `[aria-disabled="true"]`                        |

Every rule carries only the tokens of its state, so the browser layers them over
the resting rule the way CSS always does, and `hoverStyle` is nothing but the
`BoxState.hover` entry. That includes the flex layout: `flex-direction`,
`justify-content` and `align-items` stay with the resting rule, because a state
rule that restated them would reset the layout — hovering a row would turn it
into a column. Hover sits inside a media query so a touch screen cannot get
stuck in a hovered look, and focus uses `:focus-visible` so a mouse click never
paints a focus ring.

The class name is a hash of the resolved styles and of every state, which keeps
the output deterministic: server rendered markup and the hydrated client agree
without any extra state, and boxes that share a style share a class.

### Semantics

| Unibox                                   | Attribute                        |
| ---------------------------------------- | -------------------------------- |
| `BoxRole.button` / `.link` / `.heading`  | `role="button"`, `link`, `heading` |
| `BoxRole.checkbox` / `.switch_`          | `role="checkbox"` / `switch`     |
| `semantics.label`                        | `aria-label`                     |
| `semantics.checked`                      | `aria-checked="true"` / `"false"` |
| `enabled: false`                         | `aria-disabled="true"`           |
| a role the user can act on               | `tabindex="0"` plus `keydown` / `keyup` |

A box with such a role enters the tab order and activates on Enter and Space,
with `preventDefault` so Space does not scroll the page. A disabled box carries
`aria-disabled`, keeps its layout, and gets no listener at all.

### Interaction

A box without callbacks renders no listeners, so static pages ship no
JavaScript for it. A tappable box also gets `cursor: pointer`. Long presses map
to pointer listeners with a 500 ms threshold and suppress the follow-up `click`,
mirroring Flutter.

## Text mapping

A `TextNode` becomes a `<span>`, so it flows inline like Flutter's `Text` does
inside a `Row`.

| Unibox          | Jaspr / CSS                                      |
| --------------- | ------------------------------------------------ |
| `fontSize`      | `font-size` in `px`                              |
| `fontWeight`    | `font-weight` (`normal` → `400`, `bold` → `700`) |
| `color`         | `color`                                          |
| `lineHeight`    | unitless `line-height`                           |
| `fontFamily`    | `font-family`                                    |
| `letterSpacing` | `letter-spacing` in `px`                         |
| `textAlign`     | `text-align`                                     |
| `maxLines`      | `-webkit-line-clamp` box                         |
| `overflow`      | `text-overflow`                                  |

Typography that the node leaves unset emits nothing, so the text inherits the
font family, size, weight and color of the page — the same contract
`DefaultTextStyle` provides in Flutter.

What the page starts from is the model's, not the browser's: `renderJaspr` emits a
`:root` rule carrying `BoxTextStyle.defaults` (16 logical pixels, black, a 1.5 line
height, no letter spacing, `font-family: system-ui`), which is what the Flutter
renderer installs as a `DefaultTextStyle` around the tree. A host that renders other
content next to the tree can restyle its own, and a host that wants a font family
states one — the family is the one token the model leaves to the application.

`maxLines` needs the prefixed box layout, since that is the only portable way to
truncate after N lines:

```css
display: -webkit-box;
-webkit-box-orient: vertical;
-webkit-line-clamp: 2;
overflow: hidden;
```

An `ellipsis` without `maxLines` truncates the single line instead
(`white-space: nowrap; overflow: hidden; text-overflow: ellipsis`), while `clip`
only hides the overflow.

Inside a clamp, `clip` cannot be honoured: `-webkit-line-clamp` always ends the
last line with an ellipsis and `text-overflow: clip` does not remove it, so a
`maxLines` with `TextOverflow.clip` ellipsizes here and cuts off in Flutter. Use
`maxLines` with `TextOverflow.ellipsis` when the two have to agree.

A unitless `line-height` makes a line box `fontSize * lineHeight` tall, which is
exactly the box `TextStyle.height` produces in Flutter. Without a `lineHeight`
the browser uses the font's own metrics (`normal`), which is a length Skia does
not have to agree on — so declare it if a layout has to line up.

## Typography mapping

A `Box.textStyle` (or `BoxStyle.textStyle`) is emitted on the `<div>` as the font
properties CSS inherits by default, so every descendant picks it up without
repeating it:

| Unibox          | Jaspr / CSS                                      |
| --------------- | ------------------------------------------------ |
| `fontSize`      | `font-size` in `px`                              |
| `fontWeight`    | `font-weight`                                    |
| `color`         | `color`                                          |
| `lineHeight`    | unitless `line-height`, so descendants scale     |
| `fontFamily`    | `font-family`                                    |
| `letterSpacing` | `letter-spacing` in `px`                         |

The result matches the `DefaultTextStyle` the Flutter renderer installs, so the
same tree produces the same typography on both targets. A box without a
`textStyle` emits no font declaration at all and keeps inheriting from the page,
which is what `DefaultTextStyle` does in a Flutter application.

Text fields are replaced elements and do not inherit fonts on their own, so an
`<input>` and a `<textarea>` always emit `font: inherit`. That is the CSS
equivalent of the Flutter renderer letting a field adopt the ambient text style.

Precedence, from strongest to weakest: the tokens of the node, the tokens of its
`style`, the typography of the closest enclosing box, the page CSS, and finally
the browser default.

## Image mapping

An `ImageNode` becomes an `<img>` carrying its `src` and `alt` attributes, so
browsers can cache, lazy-load and describe the picture like any other image on
the page.

| Unibox           | Jaspr / CSS                                   |
| ---------------- | --------------------------------------------- |
| `src`, `alt`     | `src` and `alt` attributes                    |
| `width`/`height` | `width`/`height` (`double.infinity` → `100%`) |
| `fit`            | `object-fit` (`cover`, `contain`, `fill`, `scale-down`) |
| `borderRadius`   | `border-radius`                               |

Images render as `display: block`, matching the leaf box they are in Flutter: no
line box, and therefore no baseline gap beneath the picture.

`object-fit` is always written, even when the node names no fit: the model's
answer is `ImageFit.scaleDown`, which CSS spells `scale-down`. Left out, the
browser would stretch the picture over its box (`object-fit: fill`) while Flutter
scales it down, so the same tree would look squashed on one target.

A single dimension keeps the natural aspect ratio, just like an `Image` that
only constrains one side. Relative sources need no rewriting: the browser
resolves them against the page while the Flutter renderer loads them as assets.

## Link mapping

A `LinkNode` becomes a real `<a>` element, so the link keeps working without
JavaScript: middle clicks, the context menu, prefetching and crawlers all behave
like they do on any other website.

| Unibox   | Jaspr / CSS                                          |
| -------- | ---------------------------------------------------- |
| `url`    | `href`                                               |
| `newTab` | `target="_blank"` plus `rel="noopener noreferrer"`   |
| `onTap`  | `click` listener that runs alongside the navigation  |

`onTap` is attached as a plain `click` listener rather than the component's
`onClick`, because `onClick` calls `preventDefault()` and would stop the browser
from following the link. A link without `onTap` renders no listeners at all.

The anchor also declares `color: inherit` and `text-decoration: none`, which
turns off the two things a browser adds to a link on its own. A link is not a
text node, so the typography of its box has to reach it explicitly, and the
Flutter renderer draws the child of a link exactly as it is — no link colour, no
underline — so leaving the user agent styles in place would make the same tree
look different on the two targets.

Relative destinations need no rewriting, and the Flutter renderer delegates the
actual navigation to the host through `UniboxLinkScope`.

## Stack mapping

A `StackNode` becomes a `<div>` with `position: relative` and `display: grid`.
Every child is placed in the same grid cell, so the children overlap and paint in
source order (last on top) while the container still sizes to its largest child —
a `Stack` with `Clip.none` in Flutter.

| Unibox                     | Jaspr / CSS                                          |
| -------------------------- | ---------------------------------------------------- |
| `StackNode`                | `position: relative` plus `display: grid`            |
| `StackNode.width`/`height` | `width`/`height` (`double.infinity` → `100%`)        |
| plain child                | `grid-area: 1 / 1` cell wrapper, `place-self: start`  |
| `PositionedNode`           | `position: absolute` plus `top`/`right`/`bottom`/`left` |

Each child is wrapped in a cell `<div>`: the overlap is a property of the
container, and the rendered child already carries its own inline styles.

`place-self: start` is what keeps that child its own size. A grid item stretches
to fill its cell by default, while a Flutter `Stack` lays a child that is not
positioned out at its natural size in the top start corner — so without the
declaration a badge would grow to the size of the stack here and stay small there.

A `PositionedNode` without any offset keeps its natural place, exactly like the
`Positioned` widget Flutter never needed, and a `PositionedNode` rendered
outside a stack falls back to its child.

## Text input mapping

A `TextInputNode` becomes `<input type="text">`, `<input type="password">` when
`obscureText` is set, or a `<textarea>` when `multiline` is set. The field is
stretched over the available width with `box-sizing: border-box` — the layout a
Flutter `TextField` gets from the column it lives in — and it inherits the font,
the colour and the line height of its box, which is what sizes it.

A text area starts at one row and never shows the resize grip of a browser,
because a Flutter field starts at one line and has no grip: `rows` is written out
from `maxLines` and `resize: none` is part of the field styles.

Everything a browser draws around a form field by itself is stripped: no border,
no padding, no background, and no focus ring. A Flutter field carries no Material
decoration either, so the box around a field is the only thing that draws one, on
both targets.

The focus ring goes too, because a browser draws it around the field itself: the
field sits inside the padding and the border of the box that wraps it, so a
focused field would show a second frame inside the one the tree asked for, and
Flutter has no counterpart to it — a collapsed `TextField` only draws its caret.
The caret is what is left: the tree cannot draw a focus frame around a field
either, because a box raises its `focus` state by being focused itself rather than
by holding a focused child, and a browser matches `:focus-visible` on the focused
element only.

| Unibox        | Jaspr / HTML                                           |
| ------------- | ------------------------------------------------------ |
| `value`       | `value` attribute (input) or text content (text area)  |
| `placeholder` | `placeholder` attribute                                |
| `obscureText` | `type="password"`                                      |
| `multiline`   | `<textarea>` instead of `<input>`                      |
| `maxLines`    | `rows` of the text area                                |
| `onChanged`   | `input` listener                                       |
| `onSubmitted` | `keydown` listener: `Enter`, or `Ctrl`/`Cmd` + `Enter` |

A `value` makes the field controlled: rendering the node again with a new value
replaces what the user typed. Without a value the field keeps its own content and
only reports changes through `onChanged`.

`onSubmitted` fires on a bare `Enter` for a single line field and on
`Ctrl`/`Cmd` + `Enter` for a text area, because a plain `Enter` inserts a newline
there — the same split a Flutter `TextField` has with a multiline keyboard type.

Both listeners read the field through the `package:web` DOM types Jaspr itself
uses for `EventCallback`, which `universal_web` re-exports on every platform.

## Testing

```sh
dart test
```

Component tests use `jaspr_test`; `test/support/harness.dart` exposes
`pumpNode`, `elementOf`, `stylesOf`, `classesOf`, `attributesOf` and `cssOf`
helpers to assert on the rendered DOM.

`test/conformance_test.dart` runs the renderer against
[`unibox_conformance`](../unibox_conformance) — the table of boxes both renderers
are checked against — through `test/support/appearance.dart`, which reads the
presentation of a box back out of the CSS this renderer emitted. The same table
is what the Flutter suite answers, which is how the two outputs are held to one
contract instead of to two opinions.
