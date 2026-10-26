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

## Box mapping

| Unibox                              | Flutter                                            |
| ----------------------------------- | -------------------------------------------------- |
| `direction: Axis.horizontal`        | `Row`                                              |
| `direction: Axis.vertical`          | `Column`                                           |
| no `direction`                      | `Column` (block-like stacking)                      |
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
| `textAlign`             | `Text.textAlign`                                                |
| `maxLines` / `overflow` | `Text.maxLines` / `Text.overflow` (`clip`, `ellipsis`)           |

Typography tokens that are left unset are not passed to Flutter, so the ambient
`DefaultTextStyle` keeps providing them.
