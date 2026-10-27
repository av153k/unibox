# Changelog

## 0.1.0

The first release of the Flutter renderer: one node tree becomes a widget tree.

- `FlutterProgress` draws a `ProgressNode` as a `CircularProgressIndicator` with the
  node's colours, size and stroke instead of the theme's.
- `renderFlutter(node)` and `node.toWidget()` render any node, and `renderNode` the
  same without re-validating a subtree that was already checked.
- A box is a `Flex` in `Padding`, `DecoratedBox`, `ClipRect`/`ClipRRect`, `SizedBox`
  and `GestureDetector`/`MouseRegion`; without a direction it is a column, and an
  empty box still renders its flex container.
- Typography is inherited through `DefaultTextStyle`, and the renderer installs
  `BoxTextStyle.defaults` around the tree so an undeclared text is typeset the same
  way the web renderer typesets it.
- `BoxTransition` becomes implicit animation: the decoration tweens through
  `DecorationTween`, a delay is an `Interval` of the longest timeline, opacity is
  `AnimatedOpacity` and a transform is a `TweenAnimationBuilder` over
  `BoxTransform`, interpolated part by part rather than as one matrix.
- Interaction states are `MouseRegion` and `Focus`, with `Enter`/`Space` activation
  on a box whose role lets the user act on it, and a state style layering over the
  resting one exactly as the browser layers a pseudo class.
- Semantics: roles, labels, checked and disabled states, `isRequired`,
  `validationResult`, `hint`, expanded, selected, hidden and live regions; a heading
  becomes `Semantics(header: true, headingLevel: n)`.
- A `TextInputNode` is a `TextField` with no Material decoration, so it occupies its
  line box like a plain `<input>` and the box around it draws the field.
- `StatefulNode` renders through `FlutterStateful`: the store is created on mount,
  subscribed, rebuilt on a notification and disposed, and an `OverlayNode` is
  presented through an `OverlayPortal` on the root overlay behind its barrier.
- `FlutterWidgetNode` embeds any widget, and `FlutterLinkScope` is where a host says
  what following a link means.
