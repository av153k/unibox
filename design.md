# Unibox Design Blueprint

## 1. Intent & Architecture
Unibox provides pure Dart layout primitives that compile natively to both Flutter Widgets and Jaspr (HTML/CSS) Components.

- **Workspace:** Dart 3.13+ workspace in `packages/`:
  - `packages/unibox_core`: Pure Dart AST & tokens. Zero dependencies (no Flutter, no Jaspr, no `dart:ui`).
  - `packages/unibox_flutter`: Depends on `unibox_core` + Flutter SDK.
  - `packages/unibox_jaspr`: Depends on `unibox_core` + `jaspr: ^0.24.0`.
- **Engineering Agency:** You have permission to diverge, adjust signatures, or simplify types where it makes sense, as long as the packages remain decoupled and work seamlessly across both platforms.

---

## 2. Shared Types & Tokens (`unibox_core`)

- **`BoxColor`**: Encapsulates 32-bit ARGB (`0xAARRGGBB`) with `.rgb()`, `.rgba()`, and presets (`black`, `white`, `transparent`).
- **`BoxSpacing`**: Represents margin/padding (`all`, `symmetric`, `only`, `zero`).
- **Dimensions**: Standard `double?` for width, height, min/max dimensions.
  - Standard numbers (`width: 250`) represent logical pixels / px.
  - `double.infinity` represents expanding to fill available space (`100%` on web, `Expanded` / infinite constraints in Flutter).
- **Layout Enums**:
  - `Axis`: `horizontal`, `vertical`.
  - `MainAlign`: `start`, `center`, `end`, `spaceBetween`, `spaceAround`, `spaceEvenly`.
  - `CrossAlign`: `start`, `center`, `end`, `stretch`.
  - `Overflow`: `visible`, `hidden`, `scroll`.
  - `ImageFit`: `cover`, `contain`, `fill`.
  - `FontWeight`: `normal`, `medium`, `semiBold`, `bold`.
  - `TextAlign`: `left`, `center`, `right`, `justify`.
  - `TextOverflow`: `clip`, `ellipsis`.

---

## 3. Primitives to Implement (`unibox_core`)

All nodes extend `abstract class UINode`.

1. **`Box`** (Layout & Container):
   - **Flat layout props:** `direction`, `mainAlign`, `crossAlign`, `gap`, `flex`, `overflow`.
   - **Direction default:** an unset `direction` resolves to `Axis.vertical` (`BoxStyle.resolvedDirection`), so every box is a flex container on every target and `gap`, `mainAlign`, `crossAlign` and a child's `flex` never silently do nothing.
   - **Dimensions:** `width`, `height`, `minWidth`, `maxWidth`, `minHeight`, `maxHeight` (`double?`).
   - **Visuals:** `padding`, `margin`, `backgroundColor`, `borderRadius` (`double?`), `border`, `shadow`.
   - **Actions:** `onTap`, `onLongPress`, `onHover`.
   - **Tokens/Overrides:** Optional `style: BoxStyle?` and `hoverStyle: BoxStyle?`.
   - `computedStyle`: Helper that overlays explicit flat parameters onto `style`.
2. **`TextNode`**: `text`, `fontSize`, `fontWeight`, `color`, `textAlign`, `maxLines`, `overflow`.
3. **`ImageNode`**: `src`, `alt`, `width`, `height`, `fit`, `borderRadius`.
4. **`LinkNode`**: `url`, `child`, `newTab`, optional `onTap`.
5. **`StackNode`**: Container for layered children (`children: List<UINode>`).
6. **`PositionedNode`**: Direct child of `StackNode` (`top`, `right`, `bottom`, `left`, `child`).
7. **`TextInputNode`**: `value`, `placeholder`, `obscureText`, `multiline`, `maxLines`, `onChanged`, `onSubmitted`.

---

## 4. Platform Mappings

### Flutter (`unibox_flutter`)
- Provide `node.toWidget()` and `renderFlutter(UINode)`.
- `Box` maps to a `Row`/`Column`; an unset direction means a column.
- `Box` with `overflow: Overflow.scroll` wraps in `SingleChildScrollView`.
- `onTap` maps to `GestureDetector`.
- `onHover` maps to `MouseRegion`.
- `LinkNode` renders child with tap navigation.
- `StackNode` / `PositionedNode` map to Flutter `Stack` and `Positioned`.
- `TextInputNode` renders managed `TextField`.

### Jaspr (`unibox_jaspr`)
- Provide `node.toComponent()` and `renderJaspr(UINode)`.
- Refer to `https://jaspr.site/llms.txt` for Jaspr 0.24 syntax.
- `Box` renders a `<div>` with `boxSizing: BoxSizing.borderBox`.
- Map layout to CSS flexbox (`display: flex`, `gap`, etc.); a box without a
  direction is a flex column.
- `width == double.infinity` maps to `100.percent`.
- `LinkNode` outputs a native `<a>` tag with `href` and `target`.
- `StackNode` renders `<div style="position: relative">`.
- `PositionedNode` renders `<div style="position: absolute">`.
- `TextInputNode` renders `<input>` or `<textarea>`.

---

## 5. API Conventions

These rules are part of the public contract: a change that violates them is a
breaking change even when it compiles.

### 5.1 Naming
- Nodes live in `unibox_core` and extend `UINode`.
- Every node but `Box` carries the `Node` suffix. The suffix answers Flutter,
  which consumes the tree: `Text`, `Image`, `Stack` and `Positioned` are all
  widgets, so four of six names would have to be qualified anyway and the family
  is better off uniform. `Box` has no Flutter counterpart and stays unsuffixed.
- Tokens are prefixed with `Box` (`BoxColor`, `BoxSpacing`, `BoxBorder`,
  `BoxShadow`, `BoxStyle`), enums are unprefixed (`Axis`, `MainAlign`, ...).
- Renderer side classes are prefixed with `Unibox` (`UniboxBox`, `UniboxText`)
  and are internal: consumers see `renderFlutter`/`renderJaspr` and the
  `toWidget`/`toComponent` extensions. A renderer package exports only those
  names and **never** re-exports `unibox_core`, so a host file can import it next
  to `flutter/material.dart`; the `naming_test.dart` of each renderer package
  writes every export out beside that import to keep it true.
- `unibox_core` itself does not stay out of Flutter's way, and a host that needs
  both imports the tree with a prefix:
  `import 'package:unibox_core/unibox_core.dart' as core;`.
  - Reported by the analyzer: `Axis`, `BoxBorder`, `BoxShadow`, `TextOverflow`.
  - Reported by nothing: `TextAlign`, `FontWeight`. Flutter re-exports those two
    from `dart:ui`, and an SDK declaration loses to a package declaration without
    a diagnostic, so the failure surfaces later as
    `a value of type 'TextAlign' can't be assigned to a parameter of type
    'TextAlign?'`.
  - A tree in its own renderer-free library needs neither prefix nor `hide`,
    because no file sees both APIs. That is the arrangement the example uses.

### 5.2 Precedence
1. Flat node parameters (`gap`, `padding`, `fontSize`, ...).
2. `style` tokens (`BoxStyle`, `BoxTextStyle`).
3. Inherited typography from the closest ancestor box.
4. The host ambient style (Flutter `DefaultTextStyle`, page CSS).
5. Renderer defaults.

`computedStyle` exposes levels 1 and 2, so both renderers resolve the same
values. Level 3 is the only inherited level: layout, spacing and sizing are
never inherited (CSS does not inherit them either).

### 5.3 Dimensions
- `double` values are logical pixels, which the web renderer emits as `px`.
- `double.infinity` fills the available space: `100%` on the web, `Expanded`
  inside a flex parent and an infinite `BoxConstraints` elsewhere in Flutter.
- Unbounded parents plus an infinite dimension is a layout error in both
  targets, exactly like combining `double.infinity` with an unbounded
  `SizedBox` in plain Flutter.

### 5.4 Parity
- One tree, one shape: a node has to produce the same layout on both targets, so
  a default that only one of them has is a bug. `direction` is the case that
  matters: an unset direction means `Axis.vertical` everywhere rather than the
  `Column` of one target and the block flow of the other.
- A default lives in the model (`BoxStyle.resolvedDirection`), not in each
  renderer, so the two can only ever agree on it.
- A token that cannot take effect is either honoured or reported by
  `validateTree`; silently accepting it is not an option.
- Platform chrome belongs to the tree. A node never keeps a decoration its
  platform adds by itself — no Material underline under a field, no user agent
  border, focus ring or padding around an input, no user agent underline under a
  link — because the same node would then look different on the two targets.
  Whatever a field or a link should look like is expressed as a box around it.
  The focus ring is the subtle case: a browser draws it around the field, which
  sits inside the padding and the border of the box that wraps it, so keeping it
  paints a second frame inside the one the tree asked for. Dropping it leaves the
  caret as the only cue, which is the one thing both targets draw, and it is
  listed under Deferred because a field cannot be given a frame by the tree yet.
- A state rule may only contribute the tokens of its state. The browser layers
  `:hover` over the resting rule exactly like the Flutter renderer merges a
  state style, so a state rule that restated the layout would reset it.
- Parity is *tested*, not assumed: `unibox_conformance` lists the boxes every
  renderer has to present the same way and the texts every renderer has to
  typeset the same way, and each renderer suite reads the appearance back out of
  its own output — the Flutter one from the widget tree, the web one from the
  emitted CSS. A renderer that drops a token therefore fails its own suite, and
  because both answer the same entry, one target cannot be relaxed without the
  other failing.
- The contract stops where the two platforms stop agreeing, and it says so: what
  is compared is what a renderer *declares* — layout, spacing, paint, the six
  typography tokens, alignment and truncation — never what a text engine makes of
  it. Glyph rasterisation, hinting and line breaking belong to the engine, and
  `unibox_conformance/README.md` has the table that says which is which. One
  length is exempt from that, because both sides compute it the same way: a line
  box is `fontSize * lineHeight` on both. Two consequences follow, and both are
  the application's business rather than the renderer's: a tree that has to be
  pixel-stable declares its typography, because the ambient defaults differ
  (Flutter falls back to 14 logical pixels of black, a browser to 16 pixels of
  `canvastext`), and it ships the same font file to both hosts, because a family
  installed on one side only falls back with different metrics.
- The surface a tree is drawn on is host business: a `100%` box needs a root with
  a height, and a font needs a host that has one. An application declares both in
  its own idiom (`MaterialApp`, a Jaspr `Document`) and the renderer stays out of
  it.
- The *size* of that surface is host business too, which is why a breakpoint is
  not a token. A box cannot ask how wide the window is, so a page that has to
  know takes the answer as a parameter and each host produces it the way its
  medium allows: Flutter measures the window before it builds, the web host hands
  the question to CSS as a media query, because a static render happens before a
  viewport exists. Both answers reduce to the same two layouts as long as a
  hidden element is equivalent to an absent one — a `display: none` box takes no
  room, like a node that was never added.
- Approximate is allowed where the platforms genuinely differ: font face, line
  breaking, shadow blur, placeholder and focus colours, hit testing. Similar, not
  identical.

### 5.5 Interaction
- A box reacts to tap, long press, hover, focus and press. These five states
  exist on pointer, keyboard and touch input alike, so no state is web-only or
  Flutter-only.
- `enabled: false` suppresses callbacks, keeps the node in the accessibility
  tree as disabled, and never changes layout.
- Styling a state uses `stateStyles`, never a per-platform mechanism.
- Keyboard focus is opt-in: a box joins the tab order only when its
  `BoxSemantics.role` is one the user can act on. A plain container never does.
- Dragging, scrolling gestures and pointer move tracking are out of scope.

### 5.6 Non-goals
- No CSS cascade: no selectors, no specificity, no `inherit` keyword, no
  `!important`. Typography is the single inherited axis.
- No style sheet abstraction with class names; shared looks are expressed as
  `const BoxStyle` values.
- No breakpoint, no `Visibility` and no conditional node: the model describes one
  layout, and how wide the surface is belongs to the host (see 5.4).
- No widget/component wrapper API: renderers only translate nodes. `EmbedNode`
  is the single, explicit exception: host content enters the tree as an opaque
  payload that only its own renderer accepts, and any other renderer throws.

### 5.7 Compatibility
- Additions (new optional parameters, new nodes, new tokens) are minor.
- Renames and removals are breaking: keep the old name as a deprecated
  forwarding constructor or getter for at least one minor release.
- Every published change is listed in the package `CHANGELOG.md`.
