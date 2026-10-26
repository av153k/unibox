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
- [x] Task 14: Jaspr `StackNode` & `PositionedNode` — Implement `position: relative` container and `position: absolute` children with component tests.
- [x] Task 15: Jaspr `TextInputNode` — Implement `<input>` / `<textarea>` (controlled value, input/submit DOM events) with component tests.

### Phase 4: Integration & Verification
- [x] Task 16: Build an `example` package with a shared interactive form/card rendered across both Flutter and Jaspr targets.
- [x] Task 17: Run workspace-wide `dart analyze` and execute all test suites across all packages to verify zero errors and clean builds.

### Phase 5: Public API conventions
- [x] Task 18: Document the naming rule, the typography-only inheritance rule, the flat-over-style precedence and the non-goals (no CSS selectors/cascade, no drag & drop) in `design.md`, the root `README.md` and the `UINode` docstring.
- [x] Task 19: Add `Object? key` to `UINode` and every node constructor; map it to a `ValueKey` in Flutter and to the component key in Jaspr, with tests proving two reordered `TextInputNode`s keep their own text.

### Phase 6: Tree correctness (no API break)
- [ ] Task 19: Add `Object? key` to `UINode` and every node constructor; map it to a `ValueKey` in Flutter and to the component key in Jaspr, with tests proving two reordered `TextInputNode`s keep their own text.
- [x] Task 20: Add pure Dart `validateTree(UINode)` (`PositionedNode` outside `StackNode`, nested `LinkNode`, `overflow: scroll` with `mainAlign`, empty `TextNode`) exported from core and asserted by both renderers in debug builds.
- [x] Task 21: Assert in the Flutter link renderer that a link without an `UniboxLinkScope` and without `onTap` is a host configuration error, and update the existing link tests.

### Phase 7: Inherited typography
- [x] Task 22: Implement the `BoxTextStyle` token (`fontSize`, `fontWeight`, `color`, `lineHeight`, `fontFamily`, `letterSpacing`) with `merge`, `copyWith`, equality and token tests.
- [x] Task 23: Wire `textStyle` into `BoxStyle` and as a flat `Box` parameter, and give `TextNode` an optional `style: BoxTextStyle` with a `computedStyle` getter.
- [x] Task 24: Flutter renderer — wrap box children in `DefaultTextStyle` when typography is set, map the new text tokens and let `TextField` adopt the inherited style.
- [x] Task 25: Jaspr renderer — emit inherited typography on the `<div>` (`font-size`, `color`, `line-height`, ...) so CSS inheritance matches `DefaultTextStyle`.
- [x] Task 26: Refactor the example's shared card to rely on inherited typography and document the cascade precedence in all three READMEs.

### Phase 8: Interaction states & accessibility
- [x] Task 27: Add `BoxState` (`hover`, `focus`, `pressed`, `disabled`), `Box.stateStyles`, `Box.enabled` and `computedStyleFor(BoxState)`; `isInteractive` respects `enabled`.
- [x] Task 28: Add `BoxRole` and `BoxSemantics` tokens (`role`, `label`, `checked`) to core with equality and tests.
- [x] Task 29: Flutter renderer — `Focus` and keyboard activation (Enter/Space), pressed tracking, `Semantics` role/label/enabled, and no hover or pointer cursor when disabled.
- [x] Task 30: Jaspr renderer — one scoped class with `:hover` (inside `@media (hover: hover)`), `:focus-visible`, `:active` and `[aria-disabled="true"]` rules plus `role`, `aria-label`, `tabindex` and `keydown`.
- [x] Task 31: Express the example's disabled submit button with `enabled`, `stateStyles` and `semantics`, replacing the hand rolled tint and the nulled `hoverStyle`, and update the README mapping tables.

### Phase 9: Text input parity
- [x] Task 32: Core — `InputType` enum and `TextInputNode.inputType`, `enabled`, `readOnly`, `autofocus`, `onFocusChanged` and `semanticsLabel`.
- [x] Task 33: Flutter renderer — `keyboardType`, `autofillHints`, `enabled`, `readOnly`, `autofocus`, focus listener and `Semantics` label.
- [x] Task 34: Jaspr renderer — `type`, `disabled`, `readonly`, `autofocus`, `aria-label` and `focus`/`blur` listeners.

### Phase 10: Host embeds
- [ ] Task 35: Core — `abstract class EmbedNode extends UINode` with an `Object get payload`, documented as the escape hatch for host specific content.
- [ ] Task 36: Flutter — `WidgetNode(Widget)` accepted by `renderFlutter`, with an `UnsupportedError` for foreign payloads.
- [ ] Task 37: Jaspr — `ComponentNode(Component)` accepted by `renderJaspr` with the same contract.

### Phase 11: Public readiness
- [ ] Task 38: Add the MIT `LICENSE`, per package `CHANGELOG.md` files and the `repository`, `homepage`, `issue_tracker` and `topics` pubspec metadata while keeping `publish_to: none`.
- [ ] Task 39: Audit `dart doc` for all three packages, fix unresolved references and undocumented public members.
- [ ] Task 40: Add a cross target parity fixture: one table of expected declarations in the example shared package, asserted by both renderer test suites.
- [ ] Task 41: Add a GitHub Actions CI workflow (format check, `dart analyze` and all three test suites).
- [ ] Task 42: Final workspace verification (`dart analyze`, all six suites, `dart run bin/build.dart`), README refresh and `TASK_PLAN.md` completion commit.
