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
- `Box` with `direction != null` maps to `Flex` (`Row`/`Column`) with `SizedBox` gap separators.
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
- Map layout to CSS flexbox (`display: flex`, `gap`, etc.).
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
- A node carries the `Node` suffix **only** when the bare name collides with a
  Flutter widget (`Text`, `Image`, `Stack`, `Positioned`, `Link`). `Box` has no
  Flutter counterpart and stays unsuffixed.
- Tokens are prefixed with `Box` (`BoxColor`, `BoxSpacing`, `BoxBorder`,
  `BoxShadow`, `BoxStyle`), enums are unprefixed (`Axis`, `MainAlign`, ...).
- Renderer side classes are prefixed with `Unibox` (`UniboxBox`, `UniboxText`)
  and are internal: consumers see `renderFlutter`/`renderJaspr` and the
  `toWidget`/`toComponent` extensions.

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

### 5.4 Interaction
- A box reacts to tap, long press, hover, focus and press. These five states
  exist on pointer, keyboard and touch input alike, so no state is web-only or
  Flutter-only.
- `enabled: false` suppresses callbacks, keeps the node in the accessibility
  tree as disabled, and never changes layout.
- Styling a state uses `stateStyles`, never a per-platform mechanism.
- Dragging, scrolling gestures and pointer move tracking are out of scope.

### 5.5 Non-goals
- No CSS cascade: no selectors, no specificity, no `inherit` keyword, no
  `!important`. Typography is the single inherited axis.
- No style sheet abstraction with class names; shared looks are expressed as
  `const BoxStyle` values.
- No widget/component wrapper API: renderers only translate nodes.

### 5.6 Compatibility
- Additions (new optional parameters, new nodes, new tokens) are minor.
- Renames and removals are breaking: keep the old name as a deprecated
  forwarding constructor or getter for at least one minor release.
- Every published change is listed in the package `CHANGELOG.md`.
