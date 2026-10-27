# Changelog

## Unreleased

- The classes that draw a node are named after their target: `UniboxBox` is
  `FlutterBox`, and `UniboxText`, `UniboxImage`, `FlutterLink`, `FlutterStack`,
  `FlutterTextInput`, `FlutterOverlay`, `FlutterStateful`, `FlutterLinkScope` and
  `FlutterTextStyleScope` follow the same rule. Nothing else about them changed.
- An `OverlayNode` is presented by `UniboxOverlay` through an `OverlayPortal` on
  the root overlay: a barrier in the node's colour, `Escape` and a barrier press
  calling `onDismiss`, focus kept inside and handed back on exit, and the layer
  announced as a route. The overlay takes no room in its parent, and a tree that
  contains one needs an `Overlay` ancestor, which every `MaterialApp` provides.
- A `StatefulNode` renders through `UniboxStateful`: the store is created on
  mount, subscribed, `onMount` is called, the view is rebuilt when the store
  publishes, and `onUnmount` plus `dispose` run on unmount. The view's tree is drawn
  in place, so it inherits the typography and the layout around it.
- A field announces `required`, `invalid` and its description through
  `Semantics.isRequired`, `Semantics.validationResult` and `Semantics.hint`, and the
  wrapper only appears when the node said something to announce.
- `BoxSemantics.current` is announced as `selected`, which is the closest thing
  Flutter has to `aria-current`.
- A transition with parts gives each look group its own timing, and a delay becomes
  an `Interval` of the longest timeline, so an implicit animation can wait without an
  `AnimationController` of its own.
- A box with a transition always carries the opacity and transform wrappers, because
  the host can change its look without a state change; an opacity of 1 and an
  identity transform are read back as none.
- A rounded box clips its content to its radius (`ClipRRect`) instead of cutting
  square corners, for `Overflow.hidden` and for a rounded scrolling box.
- `opacity` becomes an `Opacity` and `transform` a `Transform` about the centre,
  inside the gesture handling so a scaled box is still tapped where it looks. A box
  that can change its look gets `AnimatedOpacity` and a `TweenAnimationBuilder` over
  `BoxTransform` instead, whether or not its resting look uses them, so a state that
  introduces a scale eases in rather than jumping.
- A box with a transition animates its decoration with a
  `TweenAnimationBuilder<Decoration>` from the look it painted last to the look the
  new state asks for; the five `BoxCurve` values map onto `Curves.linear`,
  `Curves.ease`, `Curves.easeIn`, `Curves.easeOut` and `Curves.easeInOut`.
- An embed is dispatched by payload type instead of by node class: a `Widget` is
  drawn as it is and a `WidgetEmbedBuilder` receives the rendered child, so a node
  class from outside this package renders here. Two drawable payloads, none, and a
  builder without a child are all reported with the types this target accepts.
- `WidgetEmbedBuilder` is exported, and `WidgetNode` carries its widget as its
  implementation.
- A heading becomes `Semantics(header: true, headingLevel: n)`, so a screen reader
  can build the same outline a browser builds from `h1`–`h6`. The text looks
  exactly as it did.
- The elements Flutter has a role for become a `SemanticsRole`: a list, its items
  and a form. The landmarks stay plain containers, because Flutter's accessibility
  tree has none.
- `expanded`, `selected`, `hidden` and `liveRegion` become the matching `Semantics`
  flags.
- An `ImageNode` always receives a `fit`, `BoxFit.scaleDown` when the node names
  none, so Flutter and the web renderer answer the question the same way instead
  of each falling back to its own platform.
- `renderFlutter` wraps the rendered tree in the typography of the model
  (`BoxTextStyle.defaults`) through a `DefaultTextStyle`, so a text that declares
  nothing is typeset at 16 logical pixels, black, with a 1.5 line height instead of
  Flutter's own fallback of 14 pixels. The style is merged over the ambient one, so
  a host keeps its font family, and a box in the tree overrides any token.
- A `TextInputNode` adopts the typography of the tree in every tree now, because
  there is always one to adopt: it used to keep the Material input style when no
  box declared typography.

## 0.1.0

The first release of the Flutter renderer.

- `renderFlutter` and `UINode.toWidget()` for every core node.
- Boxes map to `Row`, `Column`, `Stack`, `Padding`, `DecoratedBox`,
  `ClipRect`, `SingleChildScrollView`, `GestureDetector` and `MouseRegion`.
- A box without a direction maps to a `Column`, the same as `Axis.vertical`, so
  `gap`, `mainAlign`, `crossAlign` and a child's `flex` apply to every box.
- Typography is inherited through `DefaultTextStyle`; a `TextInputNode` opts in
  through `UniboxTextStyleScope`, so a field follows the box that owns it.
- Interaction states: hover, focus, press and disabled, with `Focus` and
  keyboard activation on Enter and Space, plus `Semantics` roles, labels and the
  enabled flag.
- `TextInputNode` maps to a `TextField` with the keyboard, the autofill hints
  and the enabled, read only and autofocus flags of the node.
- A field renders without Material's decoration: no underline, no content
  padding and no 48 pixel minimum height, so it occupies exactly its line box.
  That is what a plain `<input>` does on the web, and it lets the box around a
  field be the only thing that draws one.
- A box renders its flex container even when it has no children, so an empty box
  describes the same shape here as the flex container the web renderer emits.
- `UniboxBox`, `UniboxText`, `UniboxTextInput`, `UniboxLink`, `UniboxImage` and
  `UniboxStack` are exported, so a host or a test can address a rendered node
  without depending on its position in the tree.
- `WidgetNode` embeds any Flutter widget.
- Links follow their url through `UniboxLinkScope`; a link that can neither open
  nor call back is reported as a host configuration error in debug builds.
- The tree is validated before it is rendered, so an invalid tree fails while it
  is being built instead of rendering something wrong.
