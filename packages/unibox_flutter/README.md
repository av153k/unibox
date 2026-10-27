# unibox_flutter

Flutter renderer for [Unibox](../unibox_core) layout primitives.

```dart
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

const card = Box(
  width: double.infinity,
  padding: BoxSpacing.all(16),
  backgroundColor: BoxColor.white,
  borderRadius: 12,
  children: [TextNode('Hello')],
);

Widget widget = renderFlutter(card);
// or, equivalently:
Widget widget = card.toWidget();
```

Every node type also exports the widget it renders to — `UniboxBox`,
`UniboxText`, `UniboxTextInput`, `UniboxLink`, `UniboxImage`, `UniboxStack` — so
a host or a test can address a rendered node without depending on its position
in the tree.

## Box mapping

| Unibox                              | Flutter                                            |
| ----------------------------------- | -------------------------------------------------- |
| `direction: Axis.horizontal`        | `Row`                                              |
| `direction: Axis.vertical`          | `Column`                                           |
| no `direction`                      | `Column`, the same as `Axis.vertical`              |
| `gap`                               | `SizedBox` separators between children              |
| `mainAlign` / `crossAlign`          | `mainAxisAlignment` / `crossAxisAlignment`          |
| `padding` / `margin`                | inner / outer `Padding`                             |
| `width`, `height`                   | `SizedBox`                                          |
| `minWidth`, `maxWidth`, ...         | `ConstrainedBox`                                    |
| `backgroundColor`, `borderRadius`, `border`, `shadow` | `DecoratedBox` with a `BoxDecoration` |
| `overflow: Overflow.hidden`         | `ClipRect`                                          |
| `overflow: Overflow.scroll`         | `SingleChildScrollView`                             |
| `onTap` / `onLongPress`             | `GestureDetector`                                   |
| `onHover` / `hoverStyle`            | `MouseRegion` and the hovered token set             |

`width`/`height: double.infinity` expands to fill the available space. Inside a
flex parent the expanding child is wrapped in an `Expanded` (using `flex`, or
`1` when unspecified), elsewhere it is a `SizedBox` that fills the bounded
parent. An infinite dimension in an unbounded parent is a layout error, exactly
like a tight infinite `SizedBox` in plain Flutter.

## Text mapping

| Unibox                  | Flutter                                                        |
| ----------------------- | -------------------------------------------------------------- |
| `fontSize`              | `TextStyle.fontSize`                                            |
| `fontWeight`            | `TextStyle.fontWeight` (`normal` → `w400`, `medium` → `w500`, `semiBold` → `w600`, `bold` → `w700`) |
| `color`                 | `TextStyle.color`                                               |
| `lineHeight`            | `TextStyle.height` (both are a multiple of the font size)       |
| `fontFamily`            | `TextStyle.fontFamily`                                          |
| `letterSpacing`         | `TextStyle.letterSpacing`                                       |
| `textAlign`             | `Text.textAlign`                                                |
| `maxLines` / `overflow` | `Text.maxLines` / `Text.overflow` (`clip`, `ellipsis`)           |

Typography tokens that are left unset are not passed to Flutter, so the ambient
`DefaultTextStyle` keeps providing them.

## Typography mapping

A `Box.textStyle` (or `BoxStyle.textStyle`) becomes a `DefaultTextStyle` around
the children of the box, merged with whatever the host application already
provides. Text nodes below it only pass the tokens they set themselves, so the
result is plain Flutter inheritance:

```dart
const card = Box(
  textStyle: BoxTextStyle(fontSize: 16, color: BoxColor.black),
  children: [TextNode('Inherits 16px'), TextNode('Still 16px', fontWeight: FontWeight.bold)],
);
```

`TextField` is the one widget that ignores `DefaultTextStyle`, so a
`TextInputNode` inside a box that sets typography takes its style from the
ambient text style explicitly. A field without such a box keeps Material's input
style, which is what a plain `TextField` does. The box records the resolved
typography in a `UniboxTextStyleScope`, the inherited widget the field looks for.

Precedence, from strongest to weakest: the tokens of the node, the tokens of its
`style`, the typography of the closest enclosing box, the `DefaultTextStyle` of
the host application, and finally the Flutter default.

## State mapping

A box style can differ per interaction state. The states stack like CSS pseudo
classes: hover, then focus, then press, each laid over the resting style.

| Unibox state        | Flutter                                                     |
| ------------------- | ----------------------------------------------------------- |
| `BoxState.hover`    | `MouseRegion` toggling a rebuild, `hoverStyle` is its sugar  |
| `BoxState.focus`    | `Focus`, only when `semantics.role` can be acted on          |
| `BoxState.pressed`  | `GestureDetector.onTapDown` / `onTapUp` / `onTapCancel`      |
| `BoxState.disabled` | `enabled: false` on the handlers                            |
| enter / space       | `Focus.onKeyEvent` calling the `onTap` callback              |

`hoverStyle` is the long hand of `stateStyles[BoxState.hover]`; an entry in the
map wins over it. A box with a role the user can act on joins the tab order and
activates on Enter (on key down) and Space (on key up), which is what a button
does everywhere else.

`enabled: false` keeps the layout and the widget shape: the box still renders,
takes its `BoxState.disabled` style, reports itself as disabled through
`Semantics`, and gets no pointer cursor, no hover tracking and no callbacks.

## Semantics mapping

| Unibox                                  | Flutter                                                |
| --------------------------------------- | ------------------------------------------------------ |
| `BoxRole.button`                        | `Semantics(button: true)`                              |
| `BoxRole.link`                          | `Semantics(link: true)`                                |
| `BoxRole.heading`                       | `Semantics(header: true)`                              |
| `BoxRole.checkbox` + `checked`           | `Semantics(checked: …)`                                |
| `BoxRole.switch_` + `checked`            | `Semantics(toggled: …)`                                |
| `semantics.label`                        | `Semantics(label: …)`, replacing the contents           |
| `enabled`                                | `Semantics(enabled: …)`                                |
| a focusable role                         | `Semantics(focusable: true, focused: …)`                |

A box without semantics renders no extra `Semantics` node, so a plain container
costs nothing. A box with a label excludes the semantics of its contents: the
label *is* the accessible name, which keeps the announced text and the visible
text from drifting apart.

## Image mapping

| Unibox                        | Flutter                                             |
| ----------------------------- | --------------------------------------------------- |
| `src` with an `http(s)` URL   | `Image(image: NetworkImage(src))`                   |
| any other `src`               | `Image(image: AssetImage(src))`                     |
| `width` / `height`            | `Image.width` / `Image.height`                      |
| `fit`                         | `BoxFit` (`cover`, `contain`, `fill`)               |
| `alt`                         | `Image.semanticLabel` (omitted when empty)          |
| `borderRadius`                | `ClipRRect`                                          |

A source that fails to load renders an empty box with the declared dimensions
instead of throwing, so a broken image never breaks the layout.

## Link mapping

| Unibox   | Flutter                                        |
| -------- | ---------------------------------------------- |
| `child`  | the rendered child                             |
| `onTap`  | `GestureDetector.onTap`                        |
| `url`    | followed through `UniboxLinkScope`             |
| `newTab` | web only, ignored by the Flutter renderer      |

Flutter has no browser of its own, so the host application decides what
following a link means and the renderer only reports the destination:

```dart
UniboxLinkScope(
  open: (String url) => launchUrl(Uri.parse(url)),
  child: renderFlutter(page),
);
```

Links render as a click-cursor region that is exposed to screen readers as a
link. Without a scope, tapping a link only calls its own `onTap`, and a link
with neither a scope nor an `onTap` is reported as a host configuration error in
debug builds instead of silently doing nothing.

## Stack mapping

| Unibox                            | Flutter                              |
| --------------------------------- | ------------------------------------ |
| `StackNode.children`              | `Stack` children, painted in order   |
| `StackNode.width` / `height`      | `SizedBox` around the stack          |
| `PositionedNode` offsets          | `Positioned`                         |
| `PositionedNode` without offsets  | plain stack child                    |

Stacks behave like CSS `overflow: visible` and do not clip their content. A
`PositionedNode` rendered outside a `StackNode` renders its child without
applying the offsets, because offsets are relative to the enclosing stack.

## Text input mapping

| Unibox                      | Flutter                                              |
| --------------------------- | ---------------------------------------------------- |
| `value`                     | `TextEditingController` text, kept in sync           |
| `placeholder`               | `InputDecoration.collapsed(hintText: …)`              |
| `obscureText`               | `TextField.obscureText`                              |
| `multiline`                 | `minLines` / `maxLines` and `TextInputType.multiline` |
| `maxLines`                  | `TextField.maxLines` of a multiline field            |
| `onChanged` / `onSubmitted` | `TextField.onChanged` / `TextField.onSubmitted`       |

The renderer builds on Material's `TextField`, so it needs a `Material`
ancestor such as `MaterialApp`. With `value: null` the field keeps whatever the
user typed; as soon as the owner passes a value the controller follows it,
replacing the text and moving the caret to the end.

The field itself carries no decoration: no underline, no fill, no content padding
and no 48 pixel minimum height, so it occupies exactly its line box. That is what
a plain `<input>` does on the web, and it is what lets one node tree look the
same on both targets — a box that wants a field to look like a field draws the
border, the background and the padding around it. The field does adopt the
typography of its box, line height included, through `UniboxTextStyleScope`; that
is what sizes it.

## Testing

```sh
flutter test
```

Widget tests build the widgets `renderFlutter` returns. `test/conformance_test.dart`
runs the renderer against [`unibox_conformance`](../unibox_conformance) — the table
of boxes both renderers are checked against — through
`test/support/appearance.dart`, which reads the presentation of a box back out of
the widget tree this renderer built. The Jaspr suite answers the same table from
the CSS it emits, so a token that stops rendering fails a test instead of only
making the two targets drift apart.
