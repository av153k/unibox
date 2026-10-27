# unibox_material

The Material Design 3 type scale as Unibox typography tokens.

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
- **It freezes an implementation detail.** The renderers match `TextNode` by
  subtype today, but nothing promises that subclassing a node is a supported
  extension point; fifteen exported presets would make it one.

Keep those four lines in the application that wants them; this package stays two
names, and the day a preset needs a theme token it is a `BoxTextStyle` again.

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

`unibox_material` exports two names, `MaterialTypography` and `MaterialTypeRole`,
and it **does not re-export `unibox_core`**. A file that also imports Flutter can
therefore import this package without a prefix; it still needs one for the tree, as
described in the [core README](../unibox_core/README.md#beside-flutter).

## Testing

```shell
dart test
```

The suite holds every role to the specification's size, line box, tracking and
weight, checks that the table covers every role in order, and checks the two
properties the package relies on: a role is complete enough to reset what it does
not share, and it takes a theme colour without restating its geometry.

## Scope

Typography only, for now. Material's colour scheme, elevation, shape and
components are separate axes, and each one needs a decision about how it maps onto
a model that has no theme layer yet — so they are not pretended to be here.

## License

MIT, like the rest of the workspace.

