# Unibox examples

These packages render **the same node tree** with both renderers: one description,
two host applications. The description is a single page component —
`ExamplePageNode`, a `StatefulNode` — that draws a list of apartments behind a
navigation bar and a sign-up form the bar opens as a dialog over it: two
controlled text inputs, a hand drawn checkbox, a hover aware button, a link and a
status line, in a card that a barrier and `Escape` dismiss. The list scrolls under
the bar and shows a map beside it when the window is wide enough.

| Package | Role |
| --- | --- |
| `unibox_example_shared` | The page as one node (`ExamplePageNode`, with `ExampleState` and `ExampleStore`) and the parts it is built from (`buildExamplePage`, `buildApartmentsPage`, `buildSignupDialog`), plus the palette. Pure Dart, no renderer. |
| `unibox_example_flutter` | Flutter host: one file (`lib/main.dart`) — the surface, the link policy and the width the map needs. |
| `unibox_example_jaspr` | Jaspr host: one component file (`lib/main.dart`) — the node in a document — plus `wide_only.dart`, the CSS gate of the panel. |

Neither host holds state. The page owns it in `ExampleStore`; the host renders the
node through `FlutterStateful`, which creates the store, subscribes to it and
disposes it. What a host still supplies is what a node cannot know — the surface
the tree is drawn on, how a link opens, whether there is room for the map — which
is why each one is a single small file.

## One component, two small hosts

`ExamplePageNode` is a `StatefulNode<ExampleState, ExampleStore>`. Its state is
the form and whether the dialog is open, and its view is the frame, the listings
and the dialog as one tree. A field reports a value, the bar reports a
destination, the dialog reports a dismissal; each publishes a new `ExampleState`
and the renderer draws the view again. No host wires a callback, so the whole
application moves between the two targets as one node.

Flutter renders it with `FlutterStateful(node: ExamplePageNode(panel: ...))` inside
its `MaterialApp`; Jaspr renders the same node through `FlutterStateful` inside a
`Document`, which draws the first state on the server. The client build (Task 104)
is what makes a browser subscribe to the same store; until then the export is the
first frame, which is why a static document has to be told which state to start
in.

## The sign-up form is a dialog

`buildSignupDialog(...)` wraps the card in an `OverlayNode`: the node carries the
policy (`onDismiss`, the barrier, `Escape`) and sits in the tree where the view
says it belongs, above the page. Being open is therefore state of the page —
`ExampleState.signupOpen` — and `exampleView` includes the node while it is open
and leaves it out when it closes, so no view needs an overlay slot and the tree
stays immutable.

Each renderer presents it in its own idiom. Flutter puts the card in a modal on
the root overlay, with a scrim over the page, a barrier press and `Escape` both
calling `onDismiss`, and the focus it had before the dialog opened restored on
exit. The web renderer draws a fixed layer with `role="dialog"` and
`aria-modal="true"`; the barrier and `Escape` wait for the client build (Task
104), so the static export is a snapshot of the layer rather than an interactive
modal.

That is what the two documents are: `build/index.html` is the listings, and
`build/signup.html` is the same page with the dialog over it. A browser without
the client bundle can only be shown one of the two — so the entry document is the
one that can be read without dismissing anything, and the form is its own url.

## The listings page, and what makes it responsive

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
pinned where a renderer lives, not here: `packages/unibox_testing` holds one
table of boxes and the appearance each of them has to produce, and both renderer
suites render that table and read the appearance back out of their own output —
the Flutter suite from the widget tree, the Jaspr suite from the emitted CSS.

A renderer that drops a token, or starts wrapping a node in something that paints
differently, therefore fails its own suite instead of making the two renderings drift
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

## The static site

`tool/site.sh` builds both renderings into `build/site`, a directory any static host
can publish:

```shell
tool/site.sh --serve                        # http://localhost:8000/
tool/site.sh --base=/unibox/ --url=https://cedvdb.github.io/unibox/
```

| Path | What it is |
| --- | --- |
| `/` | A landing page: the two renderings side by side in two frames |
| `/showcase/` | The listings, rendered by Jaspr — HTML and CSS, no JavaScript |
| `/showcase/signup/` | The same page with the sign-up dialog over it |
| `/flutter/`, `/flutter/showcase/`, `/flutter/showcase/signup/` | The same three, rendered by Flutter |

Being open is state, and a static page cannot be clicked into existence, so the
export writes one document per destination and the Flutter app reads the path it was
served at (`signupOpenFromUrl`) to start in the matching state. A static host has no
rewrite rule either, which is why every Flutter route is a real `index.html`: the
build writes one entry document and the script copies it to each route, with the
absolute base href that lets the assets resolve from any depth.

The deployment is `.github/workflows/pages.yml` — verify, build, publish — and it
needs one setting a workflow cannot make: Settings → Pages → Source: **GitHub
Actions**.

## Flutter app

The host is `lib/main.dart`: a `MaterialApp` for the surface, an
`FlutterLinkScope` for what following a link means, and a `LayoutBuilder` that
passes the map or not. `FlutterStateful` keeps the store, so a width change
redraws the page without losing the form. The web runner is checked in
(`web/index.html`), so a browser build needs no scaffolding step:

```shell
cd example/unibox_example_flutter
flutter run -d chrome
```

The widget tests need no runner:

```shell
cd example/unibox_example_flutter
flutter test
```

## Jaspr app

The host is `lib/main.dart` as well: `ExampleApp` renders the shared node, and
`buildExampleDocument` puts it in the document (language, title, description, the
`html, body` height and the font stack). `bin/build.dart` renders that document
once per destination:

```shell
cd example/unibox_example_jaspr
dart run bin/build.dart   # writes build/index.html and build/signup.html
open build/index.html
```

Resize the window on `build/index.html`: the map appears beside the listings
from nine hundred pixels on and is gone below that, with no JavaScript involved.
There is one file per destination because being open is state, and a static
export cannot keep state — open the document you want.

Each page is a document before it is a picture: the bar is a `<nav>`, the page box
is a `<main>`, the card an `<article>`, the listings a `<ul>` of `<li>`s, the map a
`<figure>`, the page title an `<h1>`, and the confirmation a live region. None of
that changed a pixel, which is what the semantics tokens are for; open the export
in a reader or a crawler and the outline is there.

Each page also arrives with what a search engine reads before any script runs:
`<html lang="en">`, its own `<title>` and description
(`buildExampleDocument(page:)`), the text and the `role` attributes as markup, and
a `robots.txt` next to the two documents. A sitemap would need the address the
pages are served from, so it is left to the deployment.

What cannot be crawled is the navigation between the two files: the bar opens the
dialog and switches the page in host state (`onTap`), and a box with
`BoxRole.link` has no `href`, so a crawler sees two documents and no link between
them. A page that has
to be found makes sense as a `LinkNode` with a real url — which is the router work
`TASK_PLAN.md` lists as deferred.

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
