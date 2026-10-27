# Unibox examples

These packages render **the same node trees** with both renderers: one
description, two host applications. The example has two pages behind one
navigation bar — a signup card with two controlled text inputs, a hand drawn
checkbox, a hover aware button, a link and a status line, and a list of
apartments that scrolls under the bar and shows a map beside it when the window
is wide enough.

| Package | Role |
| --- | --- |
| `unibox_example_shared` | The node trees (`buildExamplePage(...)`, `buildSignupPage(...)`, `buildApartmentsPage(...)`), the form state and the callbacks. Pure Dart, no renderer. |
| `unibox_example_flutter` | Flutter host: a `StatefulWidget` owns a `SignupFormState` and the open `ExamplePage`, and renders `.toWidget()`. |
| `unibox_example_jaspr` | Jaspr host: a `StatefulComponent` owns the same two values and renders `.toComponent()`. |

Neither host lays anything out. They hold state and hand the tree the values and
the callbacks (`onNameChanged`, `onEmailChanged`, `onNewsletterToggled`,
`onSubmit`, `onNavigate`), which is what keeps the Flutter and the web result
identical.

## The second page, and what makes it responsive

`buildApartmentsPage({UINode? map})` describes one row: the listings on the left,
the map on the right. Whether the map is there is a question about the *surface*
the tree is drawn on, and no token can answer it — a box cannot ask how wide the
window is — so each host answers it in its own idiom and both end up with the
same two layouts:

- **Flutter** measures its surface, passes `buildExampleMap()` when it is at
  least `ExampleLayout.wideBreakpoint` wide and `null` otherwise. The panel is
  simply not part of the tree on a narrow window.
- **The web host** always passes the panel, wrapped in a `WideOnly` component: a
  plain `<div>` that a scoped rule hides with `display: none` and a
  `@media screen and (min-width: 900px)` rule turns into `display: contents`
  again. A static export is rendered before a viewport exists, so the answer has
  to arrive when the browser lays the page out rather than when it is built — and
  CSS already knows the width.

Hiding an element and leaving it out come to the same thing, because neither
takes room in the flex row: below the breakpoint the wrapper and the panel are
gone, above it the wrapper keeps no box of its own (`contents`) and the panel
itself is the second column. On a narrow surface the list is as wide as the page
on both targets. The number itself lives once, in
`ExampleLayout.wideBreakpoint`, so the measurement and the media query cannot
disagree.

The page scrolls, not the document. `Overflow.scroll` on the box below the
navigation is a `SingleChildScrollView` in Flutter and `overflow: auto` in CSS,
so the bar stays put and the listings move under it. The padding of the page sits
on a box *inside* the scrolling one, because Flutter puts the padding of a
scrolling box around its viewport while CSS puts it inside the scrollport; one
level in, both renderers scroll the same content.

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
confirmation, the listings, the map on a wide surface, a page box that fills the
surface the host gives it, and a list that scrolls under the bar.

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

`bin/build.dart` renders the component trees to static pages, one per page of the
example:

```shell
cd example/unibox_example_jaspr
dart run bin/build.dart   # writes build/index.html and build/apartments.html
open build/apartments.html
```

Resize the window on `build/apartments.html`: the map appears beside the listings
from nine hundred pixels on and is gone below that, with no JavaScript involved.
There is one file per page because navigation is state, and a static export
cannot keep state — open the page you want.

The static export is a snapshot of the server render: the markup, the inline
styles, the scoped hover rules and the media query are all there, but the `click`
and `input` listeners become live only once the component runs on the client (the
Jaspr client build). The shared state logic they call into is covered by the tests
of `unibox_example_shared`.

```shell
cd example/unibox_example_jaspr
dart test
```

## Shared package

```shell
cd example/unibox_example_shared
dart test
```
