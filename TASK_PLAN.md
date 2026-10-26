# Unibox Execution Plan

### Phase 1: Workspace & Core Models (`unibox_core`)
- [x] Task 1: Initialize root Dart 3.13 workspace and scaffold `unibox_core`, `unibox_flutter`, and `unibox_jaspr` (using `jaspr: ^0.24.0`).
- [x] Task 2: Implement styling tokens and enums in `unibox_core` (`BoxColor`, `BoxSpacing`, `BoxStyle`, alignments, overflow).
- [x] Task 3: Implement all 7 AST nodes in `unibox_core` (`Box`, `TextNode`, `ImageNode`, `LinkNode`, `StackNode`, `PositionedNode`, `TextInputNode`) with unit tests verifying `computedStyle` merging logic (`dart test`).

### Phase 2: Flutter Renderer (`unibox_flutter`)
- [x] Task 4: Flutter `Box` — Implement layout (Flex row/col, gap, padding, margin, sizing, background, border, tap/hover callbacks) with widget tests (`flutter test`).
- [x] Task 5: Flutter `TextNode` — Implement typography (font size, weight, color, text align, maxLines, ellipsis) with widget tests.
- [x] Task 6: Flutter `ImageNode` — Implement media rendering (`Image.network` vs `Image.asset`, dimensions, `BoxFit`, border radius) with widget tests.
- [x] Task 7: Flutter `LinkNode` — Implement link interaction (navigation/tap callback delegation) with widget tests.
- [x] Task 8: Flutter `StackNode` & `PositionedNode` — Implement layering (`Stack`) and absolute layout (`Positioned`) with widget tests.
- [x] Task 9: Flutter `TextInputNode` — Implement controlled `TextField` (state controller synchronization, obscureText, multiline, `onChanged`, `onSubmitted`) with widget tests.

### Phase 3: Jaspr Renderer (`unibox_jaspr`)
- [x] Task 10: Jaspr `Box` — Implement `<div>` (Flexbox CSS, `box-sizing: border-box`, dimensions, gap, background, border, click/hover listeners) with component tests (`dart test`).
- [x] Task 11: Jaspr `TextNode` — Implement `<span>` (typography styles, text alignment, webkit line clamp) with component tests.
- [x] Task 12: Jaspr `ImageNode` — Implement `<img>` (src, alt, dimensions, `object-fit`, border radius) with component tests.
- [x] Task 13: Jaspr `LinkNode` — Implement semantic `<a>` tag (`href`, `target: _blank`, click event override) with component tests.
- [ ] Task 14: Jaspr `StackNode` & `PositionedNode` — Implement `position: relative` container and `position: absolute` children with component tests.
- [ ] Task 15: Jaspr `TextInputNode` — Implement `<input>` / `<textarea>` (controlled value, input/submit DOM events) with component tests.

### Phase 4: Integration & Verification
- [ ] Task 16: Build an `example` package with a shared interactive form/card rendered across both Flutter and Jaspr targets.
- [ ] Task 17: Run workspace-wide `dart analyze` and execute all test suites across all packages to verify zero errors and clean builds.