# Changelog

## 0.1.0

The first release of the platform agnostic core: the tree, the values it is made of,
and the checks that keep a tree renderable.

- `Box`, `TextNode`, `ImageNode`, `LinkNode`, `StackNode`, `PositionedNode`,
  `TextInputNode`, `StatefulNode` and `OverlayNode`, every one immutable, `const`
  where its values allow, and carrying an optional `key` that keeps state attached
  to the node it belongs to.
- `Box` is a flex container with flat parameters for direction, alignment, gap,
  `flex`, overflow, size and bounds, plus padding, margin, background, radius,
  border, shadow, opacity and a transform. `styles: <BoxStyle>[...]` composes
  reusable bags of tokens left to right, and a flat parameter wins over all of them.
- Typography is the one inherited axis: `Box.textStyle` reaches the texts inside, and
  `BoxTextStyle.defaults` (16 logical pixels, normal weight, black, 1.5, no letter
  spacing) is the default both renderers install at the root of a tree.
- `BoxTransition` and `BoxTransitionPart` ease a change of look, of opacity or of a
  transform, with `BoxProperty` naming the parts and `BoxCurve` the five curves CSS
  and Flutter define the same way.
- Semantics: `BoxSemantics` with `role`, `element`, `label`, `checked`, `expanded`,
  `selected`, `hidden`, `liveRegion` and `current`, plus `BoxElement`, `BoxRole` and
  `BoxCurrent`; `TextNode.headingLevel` makes a text a heading.
- State lives in a store: `Store` is the contract a `StatefulNode` creates, and
  `StateStore` is the ready made one, with a guarded `state` setter that notifies
  nobody when the value does not change.
- `validateTree` reports the trees no renderer can honour faithfully: a positioned
  node outside a stack, a link inside a link, a scrolling box that also distributes
  its children, a list item outside a list, a caption outside a figure, an embed
  with nothing to draw, a transition that changes nothing, an opacity outside 0 to
  1, and a dismissible barrier with nothing to dismiss.
- No dependencies at all, and no `dart:ui`: a tree can be built and validated on a
  command line, on a server, or in a test with no framework around it.
