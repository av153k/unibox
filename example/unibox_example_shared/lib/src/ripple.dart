import 'dart:async';

import 'package:unibox_core/unibox_core.dart';

/// One ripple in flight: where it started and how far it has spread.
final class RippleDrop {
  /// Creates a drop at [position] that has spread [progress] of the way.
  const RippleDrop({
    required this.id,
    required this.position,
    required this.progress,
  });

  /// The identity of the drop, which keeps two presses apart.
  final int id;

  /// Where the press landed, inside the button.
  final BoxPoint position;

  /// How far the ink has spread, `0` to `1`.
  final double progress;

  /// The same drop, spread a little further.
  RippleDrop advanceTo(double next) =>
      RippleDrop(id: id, position: position, progress: next);

  @override
  bool operator ==(Object other) =>
      other is RippleDrop &&
      other.id == id &&
      other.position == position &&
      other.progress == progress;

  @override
  int get hashCode => Object.hash(id, position, progress);
}

/// The ripples a button is drawing right now.
final class RippleState {
  /// Creates a state with [drops] in flight.
  const RippleState({this.drops = const <RippleDrop>[]});

  /// The drops in flight, oldest first.
  final List<RippleDrop> drops;

  @override
  bool operator ==(Object other) =>
      other is RippleState &&
      other.drops.length == drops.length &&
      <int>[for (int i = 0; i < drops.length; i++) i]
          .every((int i) => other.drops[i] == drops[i]);

  @override
  int get hashCode => Object.hashAll(drops.map((RippleDrop drop) => drop.id));

  @override
  String toString() => 'RippleState(drops: ${drops.length})';
}

/// How long a drop takes to spread and fade.
const Duration rippleDuration = Duration(milliseconds: 450);

/// How wide the ink grows, in logical pixels.
///
/// A box does not know its own size, so the drop grows to a size that covers a
/// button and stops: a button larger than this shows ink at its centre.
const double rippleSpread = 280;

/// A press, and the ink it starts.
///
/// The ripple is state like any other: a press adds a drop, a ticker advances it,
/// and the view draws one box per drop. Nothing here knows about Flutter or the DOM,
/// which is why the same button ripples wherever a renderer subscribes to the store.
final class RippleStore extends StateStore<RippleState> {
  /// Creates a store with no ink.
  RippleStore() : super(const RippleState());

  Timer? _ticker;
  int _next = 0;

  /// Starts a drop where [position] was pressed.
  void press(BoxPoint position) {
    state = RippleState(
      drops: <RippleDrop>[
        ...state.drops,
        RippleDrop(id: _next++, position: position, progress: 0),
      ],
    );

    _ticker ??= Timer.periodic(const Duration(milliseconds: 16), (Timer _) {
      advance(const Duration(milliseconds: 16));
    });
  }

  /// Advances every drop by [delta] and drops the ones that finished.
  ///
  /// It is public so a test can drive the clock itself, which is also what keeps the
  /// store from hiding a clock of its own behind the timer.
  void advance(Duration delta) {
    final double step = delta.inMicroseconds / rippleDuration.inMicroseconds;

    final List<RippleDrop> next = <RippleDrop>[
      for (final RippleDrop drop in state.drops)
        if (drop.progress + step < 1) drop.advanceTo(drop.progress + step),
    ];

    state = RippleState(drops: next);

    if (next.isEmpty) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void onUnmount() {
    _ticker?.cancel();
    _ticker = null;
  }
}

/// A button that leaves ink where it is pressed.
///
/// A `StatefulNode` over a box: the button is the tree it always was, and the ink is
/// a second layer of boxes whose size and opacity come from the state. On a static
/// page nothing presses it, so it renders as the resting button — the ink appears the
/// day a client runtime subscribes to the store.
final class RippleButton extends StatefulNode<RippleState, RippleStore> {
  /// Creates a button labelled [label], filled with [background], pressing [onTap].
  RippleButton({
    required String label,
    required BoxColor background,
    required BoxColor foreground,
    required BoxColor ink,
    required BoxColor hover,
    required double radius,
    TapCallback? onTap,
    super.key,
  }) : super(
         create: RippleStore.new,
         view: (RippleState state, RippleStore store) => _rippleView(
           state,
           store,
           label: label,
           background: background,
           foreground: foreground,
           ink: ink,
           hover: hover,
           radius: radius,
           onTap: onTap,
         ),
       );
}

/// The button and its ink, as one stack.
///
/// Three layers, painted in this order: the fill, the ink, and the label. Only the
/// last one carries the press, and it is last on purpose. A layer drawn above the
/// gesture wins the hit test on both targets — in Flutter a box whose only
/// decoration is a radius still claims the pointer, and in CSS an element claims
/// it whatever its background — so an ink layer drawn on top would swallow the
/// press it exists to show. Underneath it costs nothing: nothing above it is
/// listening.
///
/// A stack is what a layer needs. The label's box sizes the stack, because the two
/// layers below it are positioned and take no room of their own.
UINode _rippleView(
  RippleState state,
  RippleStore store, {
  required String label,
  required BoxColor background,
  required BoxColor foreground,
  required BoxColor ink,
  required BoxColor hover,
  required double radius,
  required TapCallback? onTap,
}) {
  return StackNode(
    children: <UINode>[
      // The fill, so the ink has something to sit on.
      _layer(Box(borderRadius: radius, backgroundColor: background)),
      // The ink, clipped to the radius so a drop cannot spill out of the button.
      _layer(
        Box(
          overflow: Overflow.hidden,
          borderRadius: radius,
          children: <UINode>[
            StackNode(
              children: <UINode>[
                for (final RippleDrop drop in state.drops) _dropView(drop, ink),
              ],
            ),
          ],
        ),
      ),
      // The label, and the only layer that listens. Its hover is a wash rather than
      // a colour: it is painted above the ink, so an opaque hover would hide the
      // drop the press just started.
      Box(
        borderRadius: radius,
        padding: const BoxSpacing.symmetric(horizontal: 20, vertical: 10),
        onTap: onTap,
        onTapDown: (BoxTapEvent event) => store.press(event.position),
        semantics: const BoxSemantics(role: BoxRole.button),
        transition: const BoxTransition(duration: Duration(milliseconds: 100)),
        stateStyles: <BoxState, BoxStyle>{
          BoxState.hover: BoxStyle(backgroundColor: hover),
        },
        children: <UINode>[TextNode(label, color: foreground)],
      ),
    ],
  );
}

/// [child] stretched over the whole button, taking no room in the stack's size.
UINode _layer(UINode child) {
  return PositionedNode(top: 0, left: 0, right: 0, bottom: 0, child: child);
}

/// One drop: a circle centred on the press, growing as it fades.
UINode _dropView(RippleDrop drop, BoxColor ink) {
  final double diameter = rippleSpread * drop.progress;

  return PositionedNode(
    left: drop.position.x - diameter / 2,
    top: drop.position.y - diameter / 2,
    child: Box(
      width: diameter,
      height: diameter,
      borderRadius: diameter / 2,
      backgroundColor: ink,
      opacity: 0.16 * (1 - drop.progress),
    ),
  );
}
