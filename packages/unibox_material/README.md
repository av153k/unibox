# unibox_material

Material Design 3 for Unibox: the type scale, the colour roles and the components
built from them.

This package is pure Dart: it depends on `unibox_core` and nothing else. It does
not import Flutter, `dart:ui` or Material, so the same scale is available to a
Flutter app, a Jaspr page and a command line tool that only builds a tree.

## Why a package

Material's type scale is a set of numbers, and numbers are exactly what the model
already knows how to carry: a role is a `BoxTextStyle`, which both renderers draw
the same way. The alternative — `Theme.of(context).textTheme` on one side and a
CSS class on the other — would put the type scale in each host and let them drift,
which is the drift the workspace exists to remove.

Keeping it out of `unibox_core` is deliberate too. The core is neutral about
design systems: it has a default (16 pixels, 1.5 line height) but no opinion about
Roboto, `onSurface` or elevation. Material is one opinion, and it can be replaced
without touching a single node.

## Usage

```dart
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

const card = Box(
  padding: BoxSpacing.all(16),
  borderRadius: 12,
  backgroundColor: BoxColor.white,
  // Installed once: every text inside inherits it.
  textStyle: MaterialTypography.bodyMedium,
  children: <UINode>[
    TextNode('Order summary', style: MaterialTypography.titleLarge),
    TextNode('Two nights, one room.'),
    TextNode('Total', style: MaterialTypography.labelLarge),
  ],
);
```

Typography is the one inherited axis of the model, so a page states the role of an
area once and the texts inside only say what makes them different. A role that a
text node sets itself wins over the box above it, exactly like every other style
token.

## The scale

| Role | Size | Line box | Tracking | Weight | Used for |
| --- | --- | --- | --- | --- | --- |
| `displayLarge` | 57 | 64 | -0.25 | 400 | a hero number or a display line |
| `displayMedium` | 45 | 52 | 0 | 400 | a display line, one step down |
| `displaySmall` | 36 | 44 | 0 | 400 | the smallest display line |
| `headlineLarge` | 32 | 40 | 0 | 400 | the title of a short page |
| `headlineMedium` | 28 | 36 | 0 | 400 | a section heading |
| `headlineSmall` | 24 | 32 | 0 | 400 | a heading inside a page |
| `titleLarge` | 22 | 28 | 0 | 400 | the title of a card or a dialog |
| `titleMedium` | 16 | 24 | 0.15 | 500 | a title for a smaller region |
| `titleSmall` | 14 | 20 | 0.1 | 500 | a dense row or a leading label |
| `bodyLarge` | 16 | 24 | 0.5 | 400 | the long form text of a page |
| `bodyMedium` | 14 | 20 | 0.25 | 400 | the default body text |
| `bodySmall` | 12 | 16 | 0.4 | 400 | a caption or a hint |
| `labelLarge` | 14 | 20 | 0.1 | 500 | a button or another control |
| `labelMedium` | 12 | 16 | 0.5 | 500 | a label, one step down |
| `labelSmall` | 11 | 16 | 0.5 | 500 | a dense control or a badge |

Size and line box are logical pixels (`px` on the web), tracking is extra space
between characters in the same unit, and the weight is the nearest of the four
weights the model has (`normal` 400, `medium` 500) — Material's scale only uses
those two, so nothing is approximated.

The same values are available as a table for code that walks the scale:

```dart
for (final role in MaterialTypeRole.values) {
  final style = MaterialTypography.of(role);
  // ...
}
```

`MaterialTypography.styles` is that table, keyed by `MaterialTypeRole` and ordered
like `MaterialTypeRole.values`, from `displayLarge` to `labelSmall`.

## What a role states, and what it leaves out

A role is a **complete** look: size, weight, tracking and line height are all
written down. That is what makes it safe to nest — a `titleMedium` inside a bold
heading keeps its 500 weight instead of inheriting the bold, because the role
states the weight rather than leaving it `null`.

Two tokens stay unset on purpose:

- **`color`** is Material's `onSurface` (and `onSurfaceVariant`, `primary`, ...),
  which belongs to the colour scheme and to the box that installs it. Every role
  inherits the colour of the text around it, so one scale serves a light theme, a
  dark theme and a coloured button:

  ```dart
  Box(
    backgroundColor: BoxColor.rgb(0x2D, 0x6C, 0xF3),
    // The role keeps its geometry and takes the colour of the theme.
    textStyle: MaterialTypography.labelLarge.merge(
      const BoxTextStyle(color: BoxColor.white),
    ),
    children: <UINode>[TextNode('Continue')],
  )
  ```

- **`fontFamily`** is an asset of the application, not of the scale. Unset means
  the platform's UI font on both targets; an app that ships Roboto declares it on
  the box at the root of the tree, or merges it into the roles it uses.

## Presets: values, not classes

The roles above are the whole vocabulary, so a screen usually installs one on a
box and only overrides what differs:

```dart
const Box(
  textStyle: MaterialTypography.bodyMedium,
  children: <UINode>[
    TextNode('Order summary', style: MaterialTypography.titleLarge),
    TextNode('Two nights, one room.'),
  ],
);
```

When a product needs its own names, those names belong to the product: a class of
`const` values, not a node type per role. The example does exactly this with its
`ExampleType`:

```dart
abstract final class AppType {
  static const BoxTextStyle body = MaterialTypography.bodyMedium;
  static const BoxTextStyle cardTitle = MaterialTypography.titleMedium;
  static const BoxTextStyle price = MaterialTypography.labelLarge;
}

const card = Box(
  textStyle: AppType.body, // every text inside inherits it
  children: <UINode>[
    TextNode('Order summary', style: AppType.cardTitle),
    TextNode('EUR 120', style: AppType.price, color: BoxColor.white),
  ],
);
```

A `TitleText` class would be four lines, not forty — `TextNode` takes the whole
look as one `style` field, so a preset repeats no typography token:

```dart
final class TitleText extends TextNode {
  const TitleText(super.text, {super.key, super.headingLevel})
    : super(style: MaterialTypography.titleLarge);
}
```

It is still the wrong default for a shared package, and this one does not export
one:

- **It bakes a look into a type.** The tree has no context, so `TitleText` cannot
  read a theme: a dark theme or a brand font can only change it by changing the
  class, while `MaterialTypography.titleLarge.merge(...)` changes per call.
- **It names a look like a structure.** `headingLevel` is the document level and
  typography is the look; a class called `TitleText` invites hardcoding one or
  forgetting the other, and a card title is not a heading at all.
- **It costs a second vocabulary.** `titleLarge` already means what Material
  means by it; `TitleText.medium` has to be mapped onto `titleMedium` or
  `titleSmall` and kept in step.
- **It widens a small contract.** Subclassing a node works today only because the
  renderers match a node by subtype, and this package leans on that once — for the
  card below. A promise made once, for a node that *is* a box, is a design
  decision; fifteen text presets would turn it into a habit.

The line is between a look and a component. A look has no children, so it is a
value, and a value can be themed by merging a token. A component owns children and
a surface that have to travel together, so it is a node — built by extending the
node that already draws it, which is why `MaterialCard` needs no renderer and no
conformance case. A `TitleText` is the first kind pretending to be the second.

Keep those four lines in the application that wants them. The package exports
three names, and the day a preset needs a theme token it is a `BoxTextStyle`
again.

## The palette

`MaterialPalette` is the colour half of the design system: the Material 3 roles as
`const` `BoxColor` values, with a light and a dark instance.

```dart
const palette = MaterialPalette.light;

MaterialCard(
  color: palette.surfaceContainerLow,
  border: BoxBorder(color: palette.outlineVariant),
  textStyle: MaterialTypography.bodyMedium.merge(
    BoxTextStyle(color: palette.onSurface),
  ),
  children: <UINode>[TextNode('Order summary')],
);
```

| Role | What Material paints with it |
| --- | --- |
| `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer` | an accent and the text on it |
| `surface`, `onSurface`, `onSurfaceVariant` | the page, its text, and its lower emphasis text |
| `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainerHighest` | the three surface tones a card, a sheet and a filled field sit at |
| `outline`, `outlineVariant` | a line that frames a control, and one that only separates |
| `error`, `onError` | what went wrong, and the text on it |
| `scrim` | what covers the page behind a modal |
| `hoverLayer`, `pressedLayer`, `draggedLayer` | 8%, 12% and 16% of `onSurface`, the state layers as translucent colours |

The layers are derived rather than listed, because Material states them as an
opacity over the on-surface colour: a translucent colour reads correctly over any
surface tone, which is what a CSS state layer does.

**How a colour reaches the page.** The application passes the palette to its tree
builders *and* installs the same roles as its platform theme — `ColorScheme` on a
`MaterialApp`, CSS custom properties on the web. Those two wirings belong to the
application: this package depends on `unibox_core` alone and never imports Flutter,
so it cannot install a theme even if it wanted to. A change of palette is a rebuild,
like a change of state.

## The card

`MaterialCard` is the other half of the package: a Material 3 surface with
children.

```dart
const MaterialCard(
  children: <UINode>[
    TextNode('Order summary', style: MaterialTypography.titleMedium),
    TextNode('Two nights, one room.'),
  ],
);
```

It is a `Box`, so both renderers already draw it, and every token it sets is one
the conformance table already pins — the class is a combination, not a new token:

| Token | Value | Why |
| --- | --- | --- |
| padding | `16` on every edge | the room Material gives card content |
| background | `BoxColors.white` | the surface, until a colour scheme exists |
| radius | `12` | the medium shape of Material 3 |
| shadow | `MaterialCard.elevatedShadow` | elevation level one, one of its two layers |
| typography | `MaterialTypography.bodyMedium` | inherited by the texts inside |
| layout | a column (`Box`'s default) | a card stacks its content unless told otherwise |

Every one is a parameter, so an application themes a card instead of forking it:

```dart
MaterialCard(
  color: surfaceContainerLow,
  border: const BoxBorder(color: outlineVariant),
  textStyle: MaterialTypography.bodyMedium.merge(
    const BoxTextStyle(color: onSurface),
  ),
  children: <UINode>[TextNode('Order summary')],
)
```

The layout and interaction of a box come through too — `direction`, `gap`,
`width`, `flex`, `onTap`, `stateStyles`, `semantics`, ... — so a clickable card
states `onTap` and its role, not a wrapper component. What the card does not
expose is a style bag: its own tokens are flat parameters, so a bag would lose to
them. A `Box` around it is the escape hatch, and it is the box this class builds.

**What it is not.** Material takes a card's surface from a colour scheme
(`surfaceContainerLow`), its three official variants differ by tone, and a press
ripples. None of those exist in the model yet: the surface is white, the variant
is the elevated one, and a press is `stateStyles`. A colour scheme is the next
decision, not a silent default.

## The list tile

`MaterialListTile` is the row Material builds a list out of: an optional leading
node, a title with an optional subtitle, and an optional trailing node.

```dart
MaterialListTile(
  leading: const TextNode('AL'),
  title: const TextNode('Ada Lovelace'),
  subtitle: const TextNode('ada@example.com'),
  trailing: const TextNode('2m'),
  onTap: openContact,
);
```

It is a `Box` too — a row — so neither renderer has to know the name, and every
token is a combination of ones the conformance table already pins:

| Token | Value | Why |
| --- | --- | --- |
| layout | a row, centred across, filling its width | a tile is one line of a list |
| gap | `16` between the leading node, the text and the trailing node | Material's `horizontalTitleGap` |
| padding | `16` on the sides | the room Material gives a tile |
| minHeight | `56` / `72`, or `48` / `64` when `dense` | Material's one line and two line heights |
| title | `MaterialTypography.bodyLarge` | Material's title role |
| subtitle | `MaterialListTile.subtitleTextStyle` | `bodyMedium` in `onSurfaceVariant` |
| hover, press | black at 8% and 12% | Material's state layers, spelled as translucent colours |
| role | `BoxRole.button` when it can be tapped | a tappable tile is a control, and the role is what makes it focusable |

A subtitle sits in its own box inside the text column, because typography is the
one thing this model inherits: the column states `bodyLarge` for the title and the
inner box states the subtitle style for the line under it.

The three things a colour scheme would fill in are constants for now —
`subtitleColor`, and the two state tints — and the tile says so, along with what it
is not: no ripple, no tonal surface, no `titleTextStyle` overrides beyond the two
style parameters. A `Box` around it remains the escape hatch.

## The ink well

A region that reads as tappable: `MaterialInkWell` is a `Box` around one child, whose
hover, focus and press layers are the palette's, over Material's short fade.

```dart
MaterialInkWell(
  onTap: openContact,
  borderRadius: 12,
  child: const TextNode('Ada Lovelace'),
)
```

| | |
| --- | --- |
| layers | `hoverLayer` (8%), `focusLayer` (10%), `pressedLayer` (10%) of `onSurface` |
| easing | 100 ms |
| role | `button` when `onTap` is given, so a resting region is not focusable |

There is no ripple: a splash starts at the pointer and grows over a timeline of its
own, which needs a triggered animation the model does not have. A press is a tint.

## The text field

`MaterialTextField` is a label, an outlined `Box` and a message, with a
`TextInputNode` inside the outline.

```dart
MaterialTextField(
  label: 'Email',
  value: state.email,
  onChanged: store.setEmail,
  onFocusChanged: store.setEmailFocus,
  invalid: state.emailInvalid,
  message: state.emailInvalid ? 'Enter an address with an @' : null,
)
```

| State | Outline |
| --- | --- |
| resting | `outline` |
| `focused: true` | `primary` |
| `invalid: true` | `error`, and the label and message with it |

The label sits above the field and the message below it. Material floats the label
onto the border once the field has a value, and that is an animation the model has no
timeline for. The caret, the selection, the IME and autofill are the platform's,
because the input node delegates them — so a dark app passes `palette:
MaterialPalette.dark` here *and* a matching `ColorScheme` to `MaterialApp`.

`focused` is the host's: it is the value `onFocusChanged` last reported.

## The dialog and the bottom sheet

Both are `OverlayNode`s, so they sit in the tree where the state says they belong, and
no renderer knows their names.

```dart
MaterialDialog(
  title: 'Delete listing?',
  content: const TextNode('The listing and its photos are removed.'),
  actions: <UINode>[Cancel(onTap: store.close), Delete(onTap: store.delete)],
  onDismiss: store.close,
)

MaterialBottomSheet(
  title: 'Filter listings',
  content: FilterForm(state: state, store: store),
  actions: <UINode>[Apply(onTap: store.applyFilters)],
  onDismiss: store.closeFilters,
)
```

| | Dialog | Sheet |
| --- | --- | --- |
| alignment | centre | bottom |
| surface | `surfaceContainerHigh` | `surfaceContainerLow` |
| width | 280 to 560 | up to 640 |
| barrier | `scrim`, dismissible by default | the same |
| title | `headlineSmall` in `onSurface` | the same |
| actions | a row against the end | the same |

Material's modal entrance and exit transitions are not here, and the sheet's four
corners are rounded because the model has one radius per box.

## Line heights

A `BoxTextStyle.lineHeight` is a multiple of the font size, because that is the
only form CSS (`line-height: 1.5`) and Flutter (`TextStyle(height: 1.5)`) scale
the same way. Material states its line heights in pixels, so each role writes the
division: `titleMedium` is 16 pixels with a 24 pixel line box, which is
`lineHeight: 24 / 16`.

The result is the specification's integral line box, not Flutter's rounded ratio
(`Typography.englishLike2021` writes `1.5` for that role and `1.12` for display
large). The two agree to within a fifth of a pixel per line, and using the exact
division keeps the promise the renderers are tested against: a line box is
`fontSize * lineHeight`, which is 64 pixels for `displayLarge`.

## Imports

`unibox_material` exports three names — `MaterialTypography`, `MaterialTypeRole`
and `MaterialCard` — and it **does not re-export `unibox_core`**. A file that also
imports Flutter can therefore import this package without a prefix; it still needs
one for the tree, as described in the
[core README](../unibox_core/README.md#beside-flutter).

## Testing

```shell
dart test
```

The suite holds every role to the specification's size, line box, tracking and
weight, checks that the table covers every role in order, and checks the two
properties the package relies on: a role is complete enough to reset what it does
not share, and it takes a theme colour without restating its geometry. For the
card it checks the defaults, that every one can be replaced, and that the node is
validated as the box it is. That a node extending `Box` renders on both targets is
pinned by the renderer suites, which is what lets the card exist without either of
them knowing its name.

## Scope

The type scale, the colour roles, and six components. What is deliberately not here
is written on the class that lacks it, and it is all platform behaviour rather than a
value the model could carry:

| Left out | Why |
| --- | --- |
| the ripple | a splash starts at the pointer and grows over its own timeline; a press here is a tint |
| the floating label | an animation the model has no triggered timeline for |
| the caret, the selection and the focus ring | the platform draws them for the input node |
| modal entrance and exit transitions | the same missing timeline |
| `ColorScheme`, CSS custom properties, dynamic colour | the two wirings an application owns, described in Task 96 of `TASK_PLAN.md` |
| Material's three card variants, chips, menus, navigation | not built; each is a component, not a decision |

## License

MIT, like the rest of the workspace.

