# Building Unibox components with an AI assistant

This file is for an assistant writing application code **with** Unibox. The rules for
changing Unibox itself are in [`AGENTS.md`](AGENTS.md); the full parameter tables are
in [`README.md`](README.md).

Unibox is not on pub.dev and is not in any model's training data. An assistant that
has not read this file will write Flutter widgets, call them Unibox, and invent
parameters that do not exist. Hand it three things:

1. **This file**, pasted into the context or `@`-mentioned.
2. **[`README.md`](README.md)** — the reference: every node, every token, every
   default. It is the ground truth when the two disagree.
3. **If the assistant can read files**, `packages/unibox_core/lib/src/` (the source is
   documented member by member) and `example/unibox_example_shared/lib/src/` (two
   complete pages, a form and a navigation bar, as plain Dart).

A prompt that works:

```text
Read AI_INSTRUCTIONS.md and README.md from the Unibox repository before writing any
code. Build <the component> as a Unibox node tree in a file that imports only
package:unibox_core/unibox_core.dart. Do not use Flutter, Jaspr or HTML widgets.
Return the tree, and separately the host code that owns its state.
```

## The model in six lines

- A screen is an immutable Dart tree of nodes: `Box`, `TextNode`, `ImageNode`,
  `LinkNode`, `StackNode` + `PositionedNode`, `TextInputNode`, `EmbedNode`.
- One tree, two renderers: `renderFlutter(tree)` or `tree.toWidget()` in a Flutter
  app, `renderJaspr(tree)` or `tree.toComponent()` in a Jaspr one.
- A node describes *what* is on screen, never which framework draws it. There is no
  `Text`, `Row`, `Column`, `Container`, `Colors`, `EdgeInsets`, `TextStyle` or
  `BoxFit` in the tree.
- Styling is tokens — `BoxColor` and the `BoxColors` palette, `BoxSpacing`,
  `BoxBorder`, `BoxShadow`, `BoxTextStyle`, `BoxTransform`, `BoxTransition`,
  `BoxSemantics` — collected in reusable `BoxStyle` bags.
- Everything that changes over time — form values, the open page, the window size —
  belongs to the **host** and is passed into the tree as a value and a callback.
  Nodes are immutable, their constructors are `const`, and they hold no state.
- A token that is unset has a default in the model (a box is a column, text is 16px
  black at a line height of 1.5, an image scales down), and both renderers apply it.
  Never reach for the host's default.

## The rules that make generated code run

1. **Import the tree with a prefix.** `Axis`, `TextAlign`, `FontWeight`,
   `TextOverflow`, `BoxBorder` and `BoxShadow` also exist in Flutter. In any file
   that imports Flutter or Jaspr:

   ```dart
   import 'package:flutter/material.dart';
   import 'package:unibox_core/unibox_core.dart' as core;
   ```

   Better: keep the tree in a library that imports no renderer at all, the way
   `example/unibox_example_shared/` does, and let the host import both.
2. **The node names are not Flutter's.** `TextNode`, not `Text`; `ImageNode`, not
   `Image`; `StackNode`, `PositionedNode`, `LinkNode`. `Box` keeps its bare name
   because Flutter has no `Box`.
3. **Flat parameters beat style bags.** `Box.computedStyle` merges `style`
   (deprecated) → `styles` left to right → the flat parameters. A state style
   (`hoverStyle`, `stateStyles`) overlays the resting one; `disabled` overlays all.
4. **A box is a column by default.** `direction` unset means `Axis.vertical`, and
   `mainAlign` and `crossAlign` default to `start` — not Flutter's `center` cross
   alignment and not CSS's `stretch`. Say what you mean.
5. **Dimensions are `double?` in logical pixels.** `double.infinity` fills the space
   the parent gives; `flex: 1` is the `Expanded` spelling. `gap` is the space between
   children, `padding` the space inside, `margin` the space outside.
6. **Nothing platform specific in the tree.** No `MediaQuery`, no `Theme`, no router,
   no `DateTime.now()`. Measure in the host, read the theme in the host, and pass the
   answer in as a parameter.
7. **Callbacks are `void Function()`.** `onTap`, `onLongPress`, `onHover`,
   `onChanged`, `onSubmitted`, `onFocusChanged`. The host supplies the function, and a
   node that captures a closure cannot be `const`.
8. **Give an interactive box semantics.** A box with `onTap` and no `semantics` is
   not announced as a button and is not keyboard reachable. Add
   `semantics: BoxSemantics(role: BoxRole.button, label: '…')`.
9. **Key a list.** Children of a list that can reorder take `key:` — the id of the
   model they describe — or typed text follows the position instead of the row.
10. **Do not invent a parameter.** If it is not in the README tables or in
    `packages/unibox_core/lib/src/`, it does not exist. For anything the model cannot
    express, use an `EmbedNode` with one implementation per renderer, or ask.

## Translating what a model already knows

### From Flutter

| Flutter | Unibox |
| --- | --- |
| `Container`, `Padding`, `SizedBox` | `Box(padding:, margin:, width:, height:)` |
| `Column(children: …)` | `Box(children: …)` — a column is the default |
| `Row(children: …)` | `Box(direction: Axis.horizontal, children: …)` |
| `mainAxisAlignment` / `crossAxisAlignment` | `mainAlign` / `crossAlign` |
| `Expanded(child: …)` | `flex: 1` on the child box |
| `SizedBox(height: 8)` between children | `gap: 8` on the parent |
| `Colors.white`, `Color(0xFF112233)` | `BoxColor.white`, `BoxColor(0xFF112233)` |
| `Colors.grey`, `Colors.red`, `Colors.blueGrey` | `BoxColors.grey`, `BoxColors.red`, `BoxColors.blueGrey` — the same values |
| `Color.fromRGBO(r, g, b, opacity)` | `BoxColor.rgba(r, g, b, alpha)` — its alpha is `0`–`255`, or `BoxColor.rgb(r, g, b).withOpacity(0.5)` |
| `EdgeInsets.all(16)` | `BoxSpacing.all(16)` (`.symmetric`, `.only`, `.zero`) |
| `BoxDecoration(color:, border:, borderRadius:)` | `backgroundColor`, `border`, `borderRadius` |
| `BoxShadow(color:, offset:, blurRadius:, spreadRadius:)` | `shadow: BoxShadow(...)` — same names |
| `Text('Hi', style: TextStyle(…))` | `TextNode('Hi', fontSize:, fontWeight:, color:, lineHeight:)` |
| `TextStyle.height` | `lineHeight`, a **multiple** of the font size (`1.5`, not `24`) |
| `DefaultTextStyle` | `Box(textStyle: BoxTextStyle(...))`, inherited by the texts inside |
| `Image.network(src, fit:)` | `ImageNode(src, fit: ImageFit.cover, alt: '…')` |
| `GestureDetector(onTap:)` | `Box(onTap: …)` |
| `MouseRegion` | `Box(onHover: (bool hovered) { … })` |
| `Opacity(opacity:)` | `opacity:` on the box |
| `Transform.scale`, `Transform.rotate` | `transform: BoxTransform(scale:, rotation:, offsetX:, offsetY:)` |
| `AnimatedContainer` | `transition: BoxTransition(...)` plus a `BoxState` style |
| `ClipRRect` | `overflow: Overflow.hidden` with `borderRadius` |
| `SingleChildScrollView` | `Box(overflow: Overflow.scroll)` |
| `Stack` + `Positioned` | `StackNode` + `PositionedNode` |
| `Semantics(button: true, label:)` | `semantics: BoxSemantics(role: BoxRole.button, label: …)` |
| `TextField` | `TextInputNode(value:, placeholder:, inputType:, onChanged:)` |
| `MediaQuery`, `LayoutBuilder` | host work: measure there and pass the answer in |
| a third party widget | an `EmbedNode` that carries that `Widget` in `implementations` |

### From HTML and CSS

| HTML / CSS | Unibox |
| --- | --- |
| `<div>` | `Box` |
| `display: flex; flex-direction: row` | `Box(direction: Axis.horizontal)` |
| `justify-content` / `align-items` | `mainAlign` / `crossAlign` |
| `gap` | `gap` |
| `padding` / `margin` | `padding` / `margin` (`BoxSpacing`) |
| `background-color` / `border-radius` | `backgroundColor` / `borderRadius` |
| `border: 1px solid #e5e7eb` | `border: BoxBorder(color: BoxColor.rgb(0xE5, 0xE7, 0xEB))` |
| `box-shadow` / `opacity` | `shadow` / `opacity` |
| `transform: scale(…)` | `transform: BoxTransform(scale: …)` |
| `color`, `font-size`, `font-weight`, `line-height`, `letter-spacing` | the same tokens on `TextNode` or `BoxTextStyle` |
| `overflow: hidden` / `auto` | `overflow: Overflow.hidden` / `Overflow.scroll` |
| `<a href>` | `LinkNode(url, child: …)` |
| `<img src alt>` | `ImageNode(src, alt: …)` |
| `<h1>`–`<h6>` | `TextNode('…', headingLevel: 1)` |
| `<main>`, `<nav>`, `<ul>`/`<li>`, `<article>` | `semantics: BoxSemantics(element: BoxElement.main)`, `.nav`, `.ul` + `.li`, `.article` |
| `:hover`, `:focus-visible`, `:active` | `stateStyles` / `hoverStyle` with a `BoxState` key |
| `@media (min-width: 900px)` | host work: Flutter measures, the web host uses CSS |
| `<input>`, `<textarea>` | `TextInputNode`, `TextInputNode(multiline: true)` |

## A component, end to end

A plan card. Every parameter here exists; nothing is a Flutter widget.

```dart
import 'package:unibox_core/unibox_core.dart';

/// A plan card: a title, a line of copy and a button, in one column.
UINode pricingCard({
  required String plan,
  required String price,
  required void Function() onChoose,
}) {
  return Box(
    width: 320,
    gap: 12,
    padding: BoxSpacing.all(20),
    backgroundColor: BoxColor.white,
    borderRadius: 16,
    border: BoxBorder(color: BoxColor.rgb(0xE5, 0xE7, 0xEB)),
    shadow: BoxShadow(
      color: BoxColor(0x14000000),
      offsetY: 6,
      blurRadius: 16,
    ),
    // Inherited by every text below it, the way a font property is in CSS.
    textStyle: BoxTextStyle(
      fontSize: 15,
      lineHeight: 1.5,
      color: BoxColor(0xFF111827),
    ),
    children: <UINode>[
      TextNode(plan, fontSize: 20, fontWeight: FontWeight.semiBold),
      TextNode(price),
      Box(
        direction: Axis.horizontal,
        mainAlign: MainAlign.center,
        padding: BoxSpacing.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: BoxColor.rgb(0x2D, 0x6C, 0xF3),
        borderRadius: 10,
        transition: BoxTransition(duration: Duration(milliseconds: 150)),
        hoverStyle: BoxStyle(backgroundColor: BoxColor.rgb(0x1D, 0x4E, 0xD8)),
        semantics: BoxSemantics(role: BoxRole.button, label: 'Choose $plan'),
        onTap: onChoose,
        children: <UINode>[
          TextNode(
            'Choose $plan',
            color: BoxColor.white,
            fontWeight: FontWeight.medium,
          ),
        ],
      ),
    ],
  );
}
```

What it demonstrates: a column with a `gap` instead of spacer boxes, typography set
once on the parent, a button built from a box that gains a hover look through a
state style, a transition that eases the change, and semantics that make the button
announce itself and take keyboard focus.

## The host owns state

The same tree has to be rebuilt with new values when the user types. That is host
code and it stays out of the tree file:

```dart
import 'package:flutter/material.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

/// The host owns the value; the tree only describes the field.
class EmailField extends StatefulWidget {
  const EmailField({super.key});

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return renderFlutter(
      core.Box(
        padding: core.BoxSpacing.all(12),
        children: <core.UINode>[
          core.TextInputNode(
            value: _email,
            placeholder: 'you@example.com',
            inputType: core.InputType.email,
            onChanged: (String value) => setState(() => _email = value),
          ),
        ],
      ),
    );
  }
}
```

The Jaspr host is the same shape: a `StatefulComponent`, the same values, the same
tree, rendered through `renderJaspr`. The full pair is in
[`example/`](example/README.md).

## Before you return the code

- The file that holds the tree imports `package:unibox_core/unibox_core.dart` and
  nothing else — no Flutter, no Jaspr, no `dart:ui`.
- `dart analyze` is clean, and `core.validateTree(tree)` reports no errors. It
  catches a positioned node outside a stack, a link inside a link, a scrolling box
  that also distributes its children, and a transition that changes nothing.
- Every list and map is typed — `<UINode>[...]`, `<BoxState, BoxStyle>{...}` — because
  a mixed literal otherwise infers an element type that is not the one the node takes.
- Nothing in the tree reads a clock, a window, a theme or global state.
- Buttons and links carry `semantics`; images carry `alt`; headings use
  `headingLevel` rather than a larger font.
- A list that can reorder passes `key:`, and the key is the id of the row, not its
  index.
- If a widget or a plugin is needed that Unibox does not model, it is an `EmbedNode`
  with one implementation per renderer — never a host widget smuggled into a box.

## Where the rest of the API is

| Need | Read |
| --- | --- |
| Every `Box` parameter and its default | [`README.md#box`](README.md#box) |
| Text, typography and inheritance | [`README.md#textnode`](README.md#textnode), [`#typography`](README.md#typography) |
| Images, links, stacks, inputs, embeds | [`#imagenode`](README.md#imagenode), [`#linknode`](README.md#linknode), [`#stacknode-and-positionednode`](README.md#stacknode-and-positionednode), [`#textinputnode`](README.md#textinputnode), [`#embednode`](README.md#embednode) |
| Motion, states and semantics | [`#motion`](README.md#motion), [`#semantics`](README.md#semantics) |
| What the tree leaves to the host | [`#what-the-host-owns`](README.md#what-the-host-owns) |
| The model's defaults, and why | [`packages/unibox_core/README.md`](packages/unibox_core/README.md) |
| Complete trees to copy | [`example/unibox_example_shared/lib/src/`](example/unibox_example_shared/lib/src/) |
| What a token becomes on each target | [`packages/unibox_flutter/README.md`](packages/unibox_flutter/README.md), [`packages/unibox_jaspr/README.md`](packages/unibox_jaspr/README.md) |


