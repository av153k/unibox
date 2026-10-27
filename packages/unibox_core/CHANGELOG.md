# Changelog

## Unreleased

- `Store<S>` and `StateStore<S>`: a node can own state without a dependency. A
  store holds one immutable state value, notifies a listener when that value is
  replaced, drops a publish equal to the current state and ignores one after it is
  disposed, and has the `onMount`/`onUnmount` hooks a renderer calls. The listener
  list belongs to the core, so the model keeps its no-dependency rule and one store
  runs in Flutter, on a server and in a browser.
- `StatefulNode<S, C extends Store<S>>`: the one node with a lifecycle. It carries
  a factory for its store and a function of state that returns the tree to draw;
  the node never holds the store, so the tree stays a description. `createStore`
  and `viewFor` are the erased boundary a renderer uses.
- `BoxElement.figcaption`: the caption of a `figure`, so a picture can be named
  instead of holding a loose text node. `validateTree` reports a caption outside a
  figure, the same rule a list item already has.
- `TextInputNode.required`, `.invalid` and `.description`: what the form needs from a
  field, whether the value is wrong, and what the field expects — the three things
  that let a reader hear the problem at the field instead of in a status message.
- `BoxSemantics.current` (`BoxCurrent.page`, `.step`, `.location`): the item of a set
  the reader is on, for a navigation.
- `BoxColors`: the palette an interface reaches for before it has one of its own —
  `white`, `black`, `transparent`, the grey ladder (`lightGrey`, `grey`,
  `darkGrey`, `blueGrey`) and the common hues (`red`, `orange`, `yellow`, `green`,
  `teal`, `blue`, `indigo`, `purple`, `pink`, `brown`) — at the values Flutter's
  `Colors` gives the same names, so a tree that names one matches the widgets
  drawn around it.
- `BoxProperty` and `BoxTransitionPart`: a transition can ease one part of a look before
  another. `BoxTransition.parts` overrides the base duration and curve per look,
  `timingOf` resolves one look, `totalDuration` is the longest `delay + duration` and
  `BoxProperty.paint` is the four paint properties as one set, because a `BoxDecoration`
  interpolates as a unit.
- `Box.styles`: a list of style bags, merged left to right, with flat parameters
  winning over all of them. **Breaking:** `style` is deprecated in favour of it.
- `validateTree` reports a part that names no look, a look eased by two parts, a part
  that changes nothing, and paint eased at two speeds.
- `BoxStyle.opacity` and `BoxStyle.transform` (`BoxTransform`: `scale`, `rotation`
  in degrees, `offsetX`, `offsetY`), plus the flat `Box.opacity` and
  `Box.transform`. Both paint the box without giving it different room, and both are
  covered by a `BoxTransition`, so a state can shrink a control or fade a row and
  have it ease.
- A transform is applied about the centre in one fixed order — translate, rotate,
  scale — because CSS and Flutter both compose matrices left to right;
  `BoxTransform.lerp` interpolates the parts, not the composed matrix, so a turning
  box does not shrink through the middle.
- `validateTree` reports an opacity outside `0` to `1`.
- `BoxTransition` (a duration and a `BoxCurve`) and `BoxStyle.transition`, so the
  change from a resting look to a state look can be eased. It covers the paint
  tokens — background, border colour, radius, shadow — and never layout, and the
  five curves are the ones CSS and Flutter share the control points of.
- `BoxCurve` (`linear`, `ease`, `easeIn`, `easeOut`, `easeInOut`).
- `validateTree` reports a transition that changes nothing and one declared on a
  state style instead of the resting one.
- `EmbedNode` carries `implementations` instead of a single `payload`: one opaque
  object per renderer that can draw the node, of which a renderer takes the first
  whose type it understands. The model still names no platform, so a renderer can
  draw a node class this package has never heard of. **Breaking:** `payload` is
  deprecated in favour of `implementations`.
- An embed can wrap one child (`child`), which its implementations receive, because
  an effect is a wrapper and not a leaf; `children` exposes it, so validation and
  the renderers reach it like any other subtree.
- `validateTree` reports an embed that carries no implementation at all.
- `TextNode.headingLevel` (1 to 6) makes a text a heading, and
  `BoxSemantics.element` gives a box an element: a landmark, sectioning content, or
  a list. Neither changes a look; both are what a page needs to be a document.
- `BoxSemantics` gains the accessibility state both platforms expose: `expanded`,
  `selected`, `hidden` and `liveRegion`. A hidden box is also no longer focusable,
  so it cannot be reached by keyboard either.
- `validateTree` reports a `BoxElement.li` whose parent is not a `ul` or an `ol`.
- `ImageFit.scaleDown` and `ImageNode.resolvedFit`: an image that names no fit is
  `scaleDown` rather than whatever its renderer falls back to. Flutter's `Image`
  already scaled down, while a browser stretched the picture over its box
  (`object-fit: fill`), so the same tree was squashed on one target and letterboxed
  on the other.
- The README lists the defaults of every node and what is deliberately left to the
  host.
- `BoxTextStyle.defaults` is the typography a text is typeset in when the tree
  says nothing else: 16 logical pixels, normal weight, black, a line height of 1.5
  and no letter spacing. Both renderers install it at the root of the tree they
  render, so an undeclared text no longer inherits whichever default its host
  happens to have. The font family stays unset, because a font file is an asset of
  the application.

## 0.1.0

The first release of the platform agnostic core.

- The node tree: `Box`, `TextNode`, `ImageNode`, `LinkNode`, `StackNode`,
  `PositionedNode` and `TextInputNode`, every node with an optional `key` that
  keeps state attached to its node when a list is reordered.
- Style tokens: `BoxStyle`, `BoxTextStyle`, `BoxColor`, `BoxSpacing`,
  `BoxBorder`, `BoxShadow`, plus the semantics tokens `BoxSemantics` and
  `BoxRole`.
- Layout defaults: `BoxStyle.resolvedDirection` resolves an unset `direction` to
  `Axis.vertical`, so a box is a flex container on every target and `gap`, the
  alignment tokens and a child's `flex` apply whether or not the direction is
  written out.
- Typography inheritance: `Box.textStyle` is inherited by the descendants, every
  other token applies to the box itself.
- Interaction states: `BoxState`, `Box.stateStyles`, `Box.enabled` and
  `Box.computedStyleFor`, with `hoverStyle` as sugar for the hover entry.
- Text input parity: `InputType`, `enabled`, `readOnly`, `autofocus`,
  `semanticsLabel` and `onFocusChanged`.
- `EmbedNode`, the escape hatch for host specific content.
- `validateTree`, which reports trees that no renderer can honour.
