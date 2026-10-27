# Unibox

Unibox provides pure Dart layout primitives that compile natively to **Flutter
widgets** and **Jaspr (HTML/CSS) components** from a single description.

```dart
const card = Box(
  direction: Axis.vertical,
  gap: 8,
  padding: BoxSpacing.all(16),
  backgroundColor: BoxColor.white,
  borderRadius: 12,
  textStyle: BoxTextStyle(fontSize: 16, color: BoxColor.black),
  children: <UINode>[
    TextNode('Hello', fontWeight: FontWeight.bold),
    TextNode('Rendered by Flutter and by Jaspr.'),
  ],
);

const button = Box(
  onTap: submit,
  enabled: canSubmit,
  padding: BoxSpacing.symmetric(horizontal: 18, vertical: 12),
  backgroundColor: BoxColor.rgb(0x2D, 0x6C, 0xF3),
  stateStyles: <BoxState, BoxStyle>{
    BoxState.hover: BoxStyle(backgroundColor: BoxColor.rgb(0x1D, 0x4E, 0xD8)),
    BoxState.disabled: BoxStyle(backgroundColor: BoxColor.transparent),
  },
  semantics: BoxSemantics(role: BoxRole.button, label: 'Create account'),
  children: <UINode>[TextNode('Create account')],
);
```

What both renderers agree on:

- **One tree, two targets.** The same nodes become widgets and HTML/CSS, with
  the same layout, spacing and typography.
- **Defaults are part of the contract.** A box is a flex container on both
  targets and an unset `direction` means a column on both, so the tree keeps its
  shape and `gap`, `mainAlign`, `crossAlign` and a child's `flex` never silently
  do nothing.
- **Typography is inherited.** A box states its font tokens once and its texts
  only say what makes them different, like CSS and `DefaultTextStyle` do.
- **Interaction states in the model.** Hover, focus, press and disabled are
  `BoxState` entries, rendered as `MouseRegion`/`Focus` and as `:hover`,
  `:focus-visible`, `:active` and `[aria-disabled]`.
- **Accessibility is not an afterthought.** `BoxSemantics` turns a hand drawn
  control into a real button or checkbox, with a keyboard entry point and a
  screen reader name.
- **Fields describe themselves.** `TextInputNode` carries its input type, its
  enabled, read only and autofocus flags and its label.
- **Mistakes fail loudly.** `validateTree` reports trees no renderer can honour,
  and an embed that belongs to another target throws instead of vanishing.
- **One contract, two renderers.** `unibox_conformance` lists boxes and the
  appearance each one has to produce. Both suites read that appearance back out
  of the output they produced — the widget tree on one side, the emitted CSS on
  the other — so a token a renderer stops rendering fails its own test instead
  of quietly making the two targets look different.

## Packages

| Package | Description |
| --- | --- |
| `packages/unibox_core` | Platform agnostic AST, style tokens and layout types. No dependencies outside the Dart SDK. |
| `packages/unibox_flutter` | Flutter renderer (`renderFlutter()`, `.toWidget()`). |
| `packages/unibox_jaspr` | Jaspr renderer (`renderJaspr()`, `.toComponent()`). |
| `packages/unibox_conformance` | The presentation contract both renderers are tested against: one table of boxes, one expected appearance per box. Dev-only, not published. |

Dependencies flow in one direction only: both renderers depend on
`unibox_core`, and `unibox_core` never depends on a renderer. Both renderer
suites depend on `unibox_conformance`, which holds the table they are held to.

## Design conventions

**Naming.** `Box` is the only node without a `Node` suffix. A node only carries
the suffix when its bare name would collide with a Flutter widget that
consumers import next to this package: `Text`, `Image`, `Stack`, `Positioned`
and `Link` all exist in `flutter/widgets.dart`.

**Flat parameters win over tokens.** Every `Box` accepts flat parameters
(`gap`, `padding`, `backgroundColor`, ...) and an optional `style: BoxStyle`.
The flat parameter always overrides the matching token, so a shared style can
be specialised at the call site without a wrapper type.

**Typography is inherited, layout is not.** A box passes its `textStyle` down to
its descendants, exactly like CSS font properties and Flutter's
`DefaultTextStyle`. A text node only states the tokens that make it different.
Nothing else is inherited: a box never pushes its padding, gap or alignment onto
its children.

A value is resolved in this order, and the first match wins:

| Order | Source                                                    |
| ----- | --------------------------------------------------------- |
| 1     | the flat parameter of the node (`fontSize`, `padding`, …) |
| 2     | the node's token (`BoxStyle`, `BoxTextStyle`)             |
| 3     | the typography inherited from the closest ancestor box    |
| 4     | the ambient style of the host (`DefaultTextStyle`, page CSS) |
| 5     | the renderer default                                      |

**Dimensions.** Numbers are logical pixels (`px` on the web). `double.infinity`
means "fill the available space": `100%` in CSS, an `Expanded` or an
infinite constraint in Flutter.

**Non-goals.** Unibox is not a CSS engine. There are no selectors, no
specificity and no `!important`; every node owns its own layout and visual
tokens. Interaction is limited to states a pointer, a keyboard and a touch
screen all have: tap, long press, hover, focus and press. Dragging is out of
scope.

## Examples

[`example/`](example/README.md) contains a signup card described once and
rendered by both targets: `unibox_example_flutter` hosts it in a
`StatefulWidget`, `unibox_example_jaspr` in a `StatefulComponent`, and
`unibox_example_shared` holds the node tree and the form state they share. The
two apps are asserted to *look* the same: both compare the applied presentation
of every box, read back from their own rendered output, against one fixture in
`unibox_example_shared`.

```shell
(cd example/unibox_example_shared && dart test)
(cd example/unibox_example_jaspr && dart test)
(cd example/unibox_example_flutter && flutter test)
```

## Development

This repository is a [Dart workspace](https://dart.dev/tools/pub/workspaces).
All packages share a single resolution, so run commands from the repository
root:

```shell
# Resolve the workspace (use `flutter pub get` because it contains a Flutter package)
flutter pub get

# Static analysis across every package
dart analyze

# Tests
(cd packages/unibox_core && dart test)
(cd packages/unibox_jaspr && dart test)
(cd packages/unibox_flutter && flutter test)
```

The workspace targets Dart `^3.13.0`. Jaspr is pinned to the `0.24` line
(`^0.24.0-beta.0`, the published prerelease of that line).

Continuous integration runs the same commands on every push and pull request:
the format check, `dart analyze`, the six test suites and `dart doc` for each
package (see [`.github/workflows/ci.yml`](.github/workflows/ci.yml)).

## License

MIT, see [LICENSE](LICENSE). Every package carries a copy so it can be published
on its own; `publish_to: none` keeps the workspace out of `pub.dev` until a
release is cut deliberately.
