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
