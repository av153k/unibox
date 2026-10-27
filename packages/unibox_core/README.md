# unibox_core

Platform agnostic Unibox AST, style tokens and layout types.

This package has zero external dependencies: it never imports `dart:ui`,
Flutter or Jaspr. Renderers live in `unibox_flutter` and `unibox_jaspr`.

## Nodes and tokens

| Type              | Purpose                                                      |
| ----------------- | ------------------------------------------------------------ |
| `Box`             | flex container, the primary building block                    |
| `TextNode`        | a run of text                                                 |
| `ImageNode`       | a network or bundled image                                    |
| `LinkNode`        | a link wrapping one child                                     |
| `StackNode`       | layered children, with `PositionedNode` placing them           |
| `TextInputNode`   | a single line or multiline field                              |
| `BoxColor`, `BoxSpacing`, `BoxBorder`, `BoxShadow` | visual tokens            |
| `BoxStyle`        | a bundle of every layout and visual token                     |
| `BoxTextStyle`    | a bundle of typography tokens                                 |

## Default typography

`BoxTextStyle.defaults` is the typography a text is typeset in when the tree says
nothing else: 16 logical pixels, `FontWeight.normal`, black, a line height of 1.5
and no letter spacing. Both renderers apply it to the root of the tree they
render, so an undeclared text looks the same on both targets.

It has to live here rather than in a host, because the two hosts do not agree:
Flutter falls back to 14 logical pixels of black, a browser to 16 pixels of
`canvastext` — a colour that flips in a dark theme — at a `normal` line height. A
default that lives in the host is exactly the drift this package exists to
prevent.

The font family is the one token the default leaves unset, because a font file is
an asset of the application and not of the model. Unset means the platform's UI
font: the engine default in Flutter, the generic `system-ui` family in CSS.

## Inheritance

`Box.textStyle` (or `BoxStyle.textStyle`) is inherited by the descendants of the
box; every other token only applies to the box itself. Typography is the single
inherited axis because it is the only one CSS and Flutter agree on: a box maps to
`DefaultTextStyle` in Flutter and to the inherited font properties in CSS.

A node resolves its own typography with `computedStyle`, which merges its flat
tokens over its `style`. `Box.computedTextStyle` does the same for a box, so both
renderers resolve identical values from identical input.

## Beside Flutter

This package declares a few names that `package:flutter/material.dart` also
declares, because both describe the same things:

| Name | Beside Flutter |
| --- | --- |
| `Axis`, `BoxBorder`, `BoxShadow`, `TextOverflow` | `ambiguous_import`, reported by the analyzer |
| `TextAlign`, `FontWeight` | shadowed silently: Flutter re-exports these from `dart:ui`, and an SDK declaration loses to a package declaration with no diagnostic at all |

A file that needs the tree _and_ a renderer therefore prefixes this import:

```dart
import 'package:flutter/material.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

Widget view() => const core.Box(direction: core.Axis.vertical).toWidget();
```

Better still, keep the tree in a library of its own: a package that imports
`unibox_core` but no renderer never sees both APIs, needs neither a prefix nor
`hide`, and is where a shared Flutter/web tree belongs anyway. `unibox_flutter`
and `unibox_jaspr` never re-export this package, so importing a renderer is
always safe.

## Validation

`validateTree(node)` reports the trees no renderer can honour: a `PositionedNode`
outside a `StackNode`, a `LinkNode` nested in another `LinkNode`, and a scrolling
box that also distributes its children along the main axis. Both renderers run it
inside an assertion, so a broken tree fails while it is being built.
