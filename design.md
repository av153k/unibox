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