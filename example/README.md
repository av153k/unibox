# Unibox examples

These packages render **the same node tree** with both renderers: one
description, two host applications. The tree is a signup card with two
controlled text inputs, a hand drawn checkbox, a hover aware button, a link and
a status line.

| Package | Role |
| --- | --- |
| `unibox_example_shared` | The node tree (`buildExamplePage(buildSignupCard(...))`), the form state and the callbacks. Pure Dart, no renderer. |
| `unibox_example_flutter` | Flutter host: a `StatefulWidget` owns a `SignupFormState` and renders `.toWidget()`. |
| `unibox_example_jaspr` | Jaspr host: a `StatefulComponent` owns the same state and renders `.toComponent()`. |

Neither host lays anything out. They hold state and hand four callbacks
(`onNameChanged`, `onEmailChanged`, `onNewsletterToggled`, `onSubmit`) to the
card, which is what keeps the Flutter and the web result identical.

## Keeping the two renderings alike

Both apps render the same page, so they have to *show* the same page. That is
pinned where a renderer lives, not here: `packages/unibox_conformance` holds one
table of boxes and the appearance each of them has to produce, and both renderer
suites render that table and read the appearance back out of their own output —
the Flutter suite from the widget tree, the Jaspr suite from the emitted CSS.

A renderer that drops a token, or starts wrapping a node in something that paints
differently, therefore fails its own suite instead of making the two pages drift
apart. The apps themselves only check that the page they draw is the page the
shared tree describes: the title, the two fields, the button, the link, the
confirmation, and a page box that fills the surface the host gives it.

The rest of the parity lives in the hosts, because a host owns the surface a tree
is drawn on:

- The Flutter app inherits the platform font, the window size and a `Material`
  theme from `MaterialApp`; the Jaspr document declares `html, body { height:
  100%; margin: 0 }` so the page box has something to resolve its `100%` against,
  and asks CSS for the platform font with `font-family: system-ui, …`.
- Fields and links carry no platform chrome on either side (no Material
  underline, no user agent border, padding, focus ring or underline), so the node
  tree is the only thing that decides how they look.

What stays approximate on purpose: the exact font face, line breaking, shadow
blur, placeholder and focus colours, and hit testing. A browser and Flutter never
agree on those down to the pixel, and the goal is that the two renderings are
recognisably the same page.

## Flutter app

The app only needs the generated platform runner, which is not checked in:

```shell
cd example/unibox_example_flutter
flutter create . --platforms=web   # once: adds the generated runner
flutter run -d chrome
```

The widget tests need no runner:

```shell
cd example/unibox_example_flutter
flutter test
```

## Jaspr app

`bin/build.dart` renders the component tree to a static page:

```shell
cd example/unibox_example_jaspr
dart run bin/build.dart   # writes build/index.html
open build/index.html
```

The static export is a snapshot of the server render: the markup, the inline
styles and the scoped hover rules are all there, but the `click` and `input`
listeners become live only once the component runs on the client (the Jaspr
client build). The shared state logic they call into is covered by the tests of
`unibox_example_shared`.

```shell
cd example/unibox_example_jaspr
dart test
```

## Shared package

```shell
cd example/unibox_example_shared
dart test
```
