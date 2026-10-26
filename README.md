# Unibox

Unibox provides pure Dart layout primitives that compile natively to **Flutter
widgets** and **Jaspr (HTML/CSS) components** from a single description.

```dart
final card = Box(
  direction: Axis.vertical,
  gap: 8,
  padding: BoxSpacing.all(16),
  backgroundColor: BoxColor.white,
  borderRadius: 12,
  children: const [
    TextNode('Hello', fontSize: 20, fontWeight: FontWeight.bold),
    TextNode('Rendered by Flutter and by Jaspr.'),
  ],
);
```

## Packages

| Package | Description |
| --- | --- |
| `packages/unibox_core` | Platform agnostic AST, style tokens and layout types. No dependencies outside the Dart SDK. |
| `packages/unibox_flutter` | Flutter renderer (`renderFlutter()`, `.toWidget()`). |
| `packages/unibox_jaspr` | Jaspr renderer (`renderJaspr()`, `.toComponent()`). |

Dependencies flow in one direction only: both renderers depend on
`unibox_core`, and `unibox_core` never depends on a renderer.

## Examples

[`example/`](example/README.md) contains a signup card described once and
rendered by both targets: `unibox_example_flutter` hosts it in a
`StatefulWidget`, `unibox_example_jaspr` in a `StatefulComponent`, and
`unibox_example_shared` holds the node tree and the form state they share.

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
