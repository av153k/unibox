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

### Phase 6: Tree correctness (no API break)
- [x] Task 19: Add `Object? key` to `UINode` and every node constructor; map it to a `ValueKey` in Flutter and to the component key in Jaspr, with tests proving two reordered `TextInputNode`s keep their own text.
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
- [x] Task 35: Core — `abstract class EmbedNode extends UINode` with an `Object get payload`, documented as the escape hatch for host specific content.
- [x] Task 36: Flutter — `WidgetNode(Widget)` accepted by `renderFlutter`, with an `UnsupportedError` for foreign payloads.
- [x] Task 37: Jaspr — `ComponentNode(Component)` accepted by `renderJaspr` with the same contract.

### Phase 11: Public readiness
- [x] Task 38: Add the MIT `LICENSE`, per package `CHANGELOG.md` files and the `repository`, `homepage`, `issue_tracker` and `topics` pubspec metadata while keeping `publish_to: none`.
- [x] Task 39: Audit `dart doc` for all three packages, fix unresolved references and undocumented public members.
- [x] Task 40: Add a cross target parity fixture, later superseded by the library level contract of Phase 13: the example no longer carries presentation fixtures of its own.
- [x] Task 41: Add a GitHub Actions CI workflow (format check, `dart analyze` and all three test suites).
- [x] Task 42: Final workspace verification (format check, `dart analyze`, all six suites, `dart doc`), README refresh and `TASK_PLAN.md` completion.
- [x] Task 43: Give an unset `direction` one meaning: `BoxStyle.resolvedDirection` resolves it to `Axis.vertical` and both renderers derive the flex layout from it, so `gap`, `mainAlign`, `crossAlign` and a child's `flex` apply to every box instead of silently doing nothing, and a direction-less box stops stacking in Flutter while flowing inline on the web.

### Phase 12: The two renderings look the same
- [x] Task 44: Flutter renderer — render a text input without Material's chrome (`InputDecoration.collapsed`), so the field is as tall as its line box and the surrounding box decides how it looks, and export the widget each node renders to.
- [x] Task 45: Jaspr renderer — strip the browser form chrome from `<input>`/`<textarea>` (`border: none`, no padding, no background, no focus ring, inherited colour) and the UA underline from `<a>`, so a field and a link look like their Flutter counterparts.
- [x] Task 46: Example shared — one line height on the card typography and the two fields wrapped in a shared `Box`, so both targets draw the same bordered field; the font family stays a host decision, because a CSS font stack is not a Flutter font family.
- [x] Task 47: Jaspr host — render the example through a `Document` that gives the page's `100%` box a height to resolve against (`html, body { height: 100%; margin: 0 }`), and regenerate `build/index.html`.

### Phase 13: One contract for every token
- [x] Task 48: `unibox_conformance` — a dev-only package holding the contract: `BoxAppearance` (direction, alignment, gap, padding, margin, width, height, background, radius, border), `differencesFrom` (absent equals zero, a border colour only counts when a border is drawn) and `boxCases`, one case per token plus one with all of them, with a suite that checks the table itself.
- [x] Task 49: Both renderer suites — render every case and read the appearance back out of the rendered output (`test/support/appearance.dart` walking the widget tree in `unibox_flutter`, parsing the emitted CSS in `unibox_jaspr`), never out of the node tree, so a renderer that drops a token fails its own suite and neither target can be relaxed alone.
- [x] Task 50: Jaspr renderer — strip the browser's native focus ring from a field (`outline: none`), because the ring is drawn around the field inside the padding and border of the box that wraps it ("a box inside a box" on focus) and Flutter has no counterpart to it; a focused field is a state style, not platform chrome.
- [x] Task 51: Remove the example level parity fixtures (`CardParity`, both `visual_facts.dart` extractors, both `parity_test.dart`) now that the contract lives in the library, keeping the app level tests and moving the "fills the host surface" check into the Flutter app suite.
- [x] Task 52: Docs and CI — record the contract in the package, renderer and example READMEs, the CHANGELOGs, `design.md` and the workflow, alongside `dart test` for every package.


### Phase 14: A second page behind a navigation bar
- [x] Task 53: Example shared — split the palette and the typography out of the card into `theme.dart`, and add the tokens the second page needs (nav item, listing, price, map panel).
- [x] Task 54: Example shared — `ExamplePage` (`signup`, `apartments`), `ExampleLayout.wideBreakpoint` and `buildExamplePage({current, onNavigate, page})`: one frame with a navigation bar of boxes, one item per page, highlighted while its page is open and wired through `onTap` exactly like the form's opt-in.
- [x] Task 55: Example shared — `buildApartmentsPage({UINode? map})`: the listings in a three-part column, the map in a two-part column beside it, the page itself scrolling under the bar (`Overflow.scroll`, padding one level in so both renderers scroll the same content) and `buildExampleMap()` as a coloured panel.
- [x] Task 56: Example hosts — both keep the open `ExamplePage` next to the form state. Flutter answers the breakpoint with `MediaQuery.sizeOf` and passes the map or `null`; the Jaspr host always passes it inside a `WideOnly` component whose base rule is `display: none` and whose `@media screen and (min-width: 900px)` rule is `display: contents`, because a static render runs before a viewport exists and a hidden panel has to take the whole column with it. Neither rule is inline, or it would beat the media query.
- [x] Task 57: Example Jaspr — `buildExampleDocument({page})` and `bin/build.dart` write one static file per page (`index.html`, `apartments.html`), since a static export cannot keep the navigation state; resizing `apartments.html` is what exercises the breakpoint without a client bundle.
- [x] Task 58: Tests — shared (`page_test`, `apartments_test`, the signup page in `signup_card_test`, a shared `test/support/tree.dart` with the recording host), Flutter (navigate, come back with the form intact, map beside the list, no map on a narrow surface, scroll under the bar) and Jaspr (listings, one scroll region, media query, no map on the card page, `role="link"` items, the export's second file).
- [x] Task 59: Docs — `example/README.md`, the root `README.md` (which still described a fixture the example no longer carries), `design.md` §5.4 and §5.6: the size of the surface is host business, so a breakpoint is not a token.

### Phase 15: Structure and semantics (headings, landmarks, accessibility state)
- [x] Task 60: Core — `TextNode.headingLevel` (`int?`, 1 to 6, asserted in the constructor) with the doc rule that a heading is a *text*: it renders `<h1>`–`<h6>` on the web and a `Semantics(header: true, headingLevel: n)` in Flutter, so both targets state the same level. `BoxRole.heading` stays for a heading that cannot be written as one text node.
- [x] Task 61: Core — `BoxElement` (`div`, `main`, `nav`, `header`, `footer`, `aside`, `section`, `article`, `form`, `figure`, `ul`, `ol`, `li`) as `BoxSemantics.element`, so a box can say what it *is* and not only what it looks like. `validateTree` reports a `li` whose parent is not a `ul` or an `ol`, which is the one combination HTML forbids.
- [x] Task 62: Core — `BoxSemantics` gains the accessibility state both platforms expose: `expanded`, `selected`, `hidden` and `liveRegion`, wired through `copyWith`, equality and `toString`, with node tests.
- [x] Task 63: Flutter renderer — a heading becomes `Semantics(header: true, headingLevel: n)` around the `Text`; the elements Flutter has a role for become `SemanticsRole.list` (`ul`, `ol`), `SemanticsRole.listItem` (`li`) and `SemanticsRole.form` (`form`); the four state tokens become the `Semantics` flags of the same name, and `hidden` also excludes the subtree from the tree.
- [x] Task 64: Jaspr renderer — a heading renders `<h1>`–`<h6>` with the user agent styles cancelled (`margin: 0` and inherited size and weight) so the tree's typography still governs; an element renders its own tag rather than a `<div>` (`<main>`, `<nav>`, `<ul>`, `<li>`, `<figure>` with its margin reset, ...), `role` is only emitted for the roles an element does not already imply, and the four state tokens become `aria-expanded`, `aria-selected`, `aria-hidden` and `aria-live`.
- [x] Task 65: Tests — core (level range, element defaults, `li` validation, state equality), Flutter (heading semantics, roles, flags, hidden subtree) and Jaspr (heading tag and reset, element tags, implied-role suppression, `aria-*`), plus the conformance suite kept green.
- [x] Task 66: Example — the pages become a real document: `main`, `nav`, `header`, `footer`, `h1` for the page title and `h2` for a section, `figure` for the map, and a live region for the form status, so the export can be read as an outline by a crawler and a screen reader.
- [x] Task 67: Docs — `design.md` (a new §5.8: what the model says about semantics, what each target can express, and what stays host work), the package READMEs (mapping tables for elements, headings and state), the changelogs, and the SEO notes that still say a heading is only ARIA.

### Phase 16: What a real page still needs
- [ ] Task 68: A field can state what a form needs from it: `TextInputNode.required`, `.invalid` and `.description`, rendered as `aria-required`, `aria-invalid` and `aria-describedby` (plus `Semantics.isRequired` in Flutter), so a validation message can be attached to the field it belongs to instead of sitting in a status box.
- [ ] Task 69: A box can be the current page of a navigation: `BoxSemantics.current` (`page`, `step`, `location`), rendered as `aria-current` and announced as the selected item of a set in Flutter.
- [ ] Task 70: Tabs and disclosure without ARIA guesswork: `BoxRole.tab` and `BoxRole.tablist` (or a `selected` plus a `role`) so a tab bar is a tab bar on both targets, the same way a list item already is.
- [ ] Task 71: `BoxElement.figcaption` and a `caption` slot for a figure, so the map's label can be its caption instead of a text node inside the panel.
- [ ] Task 72: A page that can be crawled between documents: a `LinkNode` that points at an exported file (`index.html`, `apartments.html`) instead of switching host state, so the static export has a real navigation path and the `role="link"` boxes can go.
- [ ] Task 73: Tables, if and when a real page needs one: `BoxElement.table`, `.tr`, `.th`, `.td` with the same validation rule a list item already has.

### Phase 17: A component of the user's own, on both targets
- [x] Task 74: Core — `EmbedNode` becomes plural and platform-agnostic: it carries `List<Object> implementations` (one per renderer that can draw it) and an optional `child` the implementations wrap, `children` exposes that child so validation reaches it, `payload` stays as a deprecated first-implementation getter, and `validateTree` reports an embed that carries no implementation at all.
- [x] Task 75: Flutter renderer — dispatch an embed by payload type instead of by node class: a `Widget` is drawn as it is, a `WidgetEmbedBuilder` receives the rendered child, two drawable implementations and none are both reported with the types this target accepts, so a node class the library has never seen renders here.
- [x] Task 76: Jaspr renderer — the same for a `Component` and a `ComponentEmbedBuilder`, so one node with one implementation per renderer is the whole extension point.
- [x] Task 77: Tests — core (implementations, wrapped child, the deprecation, the empty-embed error), Flutter and Jaspr (a user defined embed node renders, a builder receives the child, both failure modes).
- [x] Task 78: Docs — the three package READMEs state that the model names no platform and how a renderer picks its implementation, `design.md` §5.8 records that this escape hatch is outside the contract by construction, and the changelogs carry the breaking change.

### Phase 18: The portable route to effects (the ink question)
- [x] Task 79: Core — `BoxStyle.transition` (duration and curve) as a token, animating the visual tokens a state can change (background, border, radius, shadow, opacity, transform) and never the layout ones: CSS writes the `transition` on the element, Flutter swaps in the implicit animation widgets, and the conformance package grows the case shape an animation needs.
- [x] Task 80: Core — `BoxStyle.opacity` and a static `transform` (scale, translate, rotate) so a press can shrink a control and a row can fade in; both are native on both targets, and together with Task 79 they are the whole of "an effect that is not an embed".
- [ ] Task 81: Core — token keyframes with a semantic trigger (`press`, `hover`, `autoplay`): stops of the visual tokens, rendered as `@keyframes` plus `animation` and as a `TweenAnimationBuilder` keyed on the trigger. This is what lets a user build a ripple out of a clipped circle in a `Stack`; pointer-position-driven effects stay out of scope on purpose.

### Phase 19: Production ready — effects, composition and a release pass
- [x] Task 82: Core — `BoxLook` (`backgroundColor`, `borderColor`, `borderRadius`, `shadow`, `opacity`, `transform`) and `BoxTransitionPart` (looks, duration, curve, delay), so a transition can ease one part of a look before another. `BoxTransition` keeps its single duration and curve as the base and takes `parts` that override it per look; `validateTree` reports the one combination the renderers cannot honour (paint properties with different timings, which would need layered decorations) and points at nesting a box instead.
- [x] Task 83: Flutter renderer — clip a rounded box to its radius. `Overflow.hidden` and the scroll viewport clip with `ClipRect` today while the web clips to `border-radius`, so a rounded card that hides its overflow is rounded in the browser and square in Flutter. The conformance table gains a case that reads the clip back.
- [ ] Task 84: Both renderers — honour the parts. Jaspr writes one `transition` entry per look, with `transition-delay`; Flutter groups the looks by timing and animates each group with its own `Interval` on a shared total, so a delay costs no controller and the paint stays one tween.
- [ ] Task 85: Core — `styles: List<BoxStyle>` on `Box`: the bags merge left to right, flat parameters win over all of them, and `style:` becomes sugar for a one-element list (deprecated). This is the composition half of the "class" idea without a name registry: no lookups, no specificity, `const` and checked.
- [ ] Task 86: Both renderers — apply the list in one place (they read `computedStyle`), with tests for the merge order and a conformance case.
- [ ] Task 87: Core — `BoxAnimation` (a `BoxTrigger` of `press`, `hover`, `focus` or `autoplay`, or a host `play` key, plus stops per `BoxLook`), rendered as scoped `@keyframes` with `animation` on the web and a `TweenSequence` on an `AnimationController` in Flutter. `play` restarts the timeline when it changes; the trigger vocabulary stays the four states the renderer can observe, so nothing platform specific enters the model. Validation: no stops, no duration, a look named twice.
- [ ] Task 88: Example — a centre-anchored ripple built out of boxes on the submit button (a centred circle that scales out and fades, clipped to the rounded box), on both hosts, with screenshots of each.
- [ ] Task 89: Production pass — every package's pubspec metadata and description, `dart doc` clean for all four, the README node reference updated with the new tokens, CHANGELOG entries for everything unreleased, and a `RELEASE.md` checklist that states the one deliberate step (`publish_to: none` off, version bumped) as a decision for the maintainer rather than something CI does.

## Decisions

- **License:** MIT, at the root and in every package.
- **Font family:** a `BoxTextStyle.fontFamily` names one family, the way Flutter
  and CSS both read it; a comma separated *stack* is a CSS construct with no
  Flutter counterpart, so it belongs to the host (`MaterialApp` theme on one
  side, a document rule on the other) and not to the tree.
- **Platform chrome:** neither renderer keeps the decoration its platform adds to
  a control (Material's field underline, the browser's input border, focus ring
  and link underline). A control looks the way the tree says it looks, which is
  what makes the same node render the same on both targets.
- **Where conformance is pinned:** in `packages/unibox_conformance`, not in
  `example/`. The contract is a property of the renderers, so it is checked by the
  renderer suites against boxes they render themselves; an example can only show
  that one card happens to look alike, and it changes whenever the card does. The
  example keeps app level tests and drops the fixture it used to carry.
- **Publishing:** publish ready but unpublished. Every package carries a
  `CHANGELOG.md`, a `LICENSE` and the repository metadata, while `publish_to:
  none` keeps `dart pub publish` from leaving the workspace by accident. Cutting
  a release means removing that one line per package.
- **Navigation:** a page switch is a `Box.onTap` in the tree and state in the
  host, like every other interaction. A router per target would have been the
  alternative, and it would have made the two navigations two different things —
  the tree would describe a page and the hosts would disagree about where it
  lives. The cost is that a static export cannot switch pages, which is why the
  example writes one file per page.
- **Responsiveness:** the breakpoint is host state, not a token. The tree takes
  the map as a parameter and each host decides whether to pass it — Flutter by
  measuring the window, the web host by asking CSS. The breakpoint constant lives
  in the shared example so the two answers cannot drift apart.

## Deferred

Deliberately out of scope for this pass, with the reason they were left:

- `Box.onScroll` and scroll position: needs a shared scroll model that neither
  `SingleChildScrollView` nor the browser state exposes the same way.
- A focus frame around a field: the browser's native ring is stripped (it sits
  inside the padding of the box around the field), so a focused field only shows
  its caret. Drawing a frame from the tree needs a `focus-within` state — Flutter
  would listen to descendants of a `Focus`, the web needs `:has(:focus-visible)` —
  which is a state model decision, not a token.
- `ImageNode.onError` / `onLoad`: callbacks that only make sense per target, and
  an embed covers them today.
- `Box.opacity`: a compositing hint rather than a layout token; it belongs with a
  future visual effects group.
- `onDoubleTap` / `onSecondaryTap`: not part of the pointer, keyboard and touch
  intersection the state model is built on.
- Generating `BoxStyle` code: 18 fields is still hand manageable; revisit above
  25.
- `UniboxTheme`: typography inheritance covers today's needs, and a theme layer
  needs a decision about token overrides first.
- Wiring the Jaspr client build into the workspace: the example renders on the
  server and writes one file per page, so the only thing missing without a client
  bundle is the click that switches pages (the media query needs no JavaScript).

