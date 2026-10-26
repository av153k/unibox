import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'render.dart';
import 'values.dart';

/// Delay after which a pressed box counts as a long press.
const Duration _longPressDuration = Duration(milliseconds: 500);

/// Renders a [core.Box] as a styled `<div>`.
///
/// A box with a [core.Box.direction] becomes a CSS flex container whose
/// `flex-direction`, `justify-content`, `align-items` and `gap` mirror the
/// `Row`/`Column` the same node renders to in Flutter. Everything else is plain
/// CSS: `width`, `height`, `padding`, `border`, `border-radius`, `box-shadow`,
/// `overflow` and friends.
///
/// A [core.Box.hoverStyle] cannot be expressed with inline styles, since they
/// always win over a `:hover` pseudo class. Instead the box is rendered as a
/// scoped `.<class>` rule plus a `.<class>:hover` rule emitted next to the
/// `<div>`. The class name is derived from the resolved styles, which keeps the
/// output deterministic and therefore identical for server side rendering and
/// client side hydration.
class UniboxBox extends StatelessComponent {
  /// Creates a renderer for [box].
  const UniboxBox({required this.box, super.key});

  /// The node being rendered.
  final core.Box box;

  @override
  Component build(BuildContext context) {
    final List<Component> children = box.children
        .map(renderJaspr)
        .toList(growable: false);
    final Map<String, EventCallback> events = _buildEvents(box);
    final Map<String, EventCallback>? listeners = events.isEmpty
        ? null
        : events;
    final Styles restingStyles = toBoxStyles(
      box.computedStyle,
      interactive: box.isInteractive,
    );

    if (!box.hasHoverStyle) {
      return div(children, styles: restingStyles, events: listeners);
    }

    final Styles hoveredStyles = toBoxStyles(
      box.computedHoverStyle,
      interactive: box.isInteractive,
    );
    final String className =
        'unibox-box-${_hashOfStyles(restingStyles, hoveredStyles)}';

    return Component.fragment(<Component>[
      Style(
        styles: <StyleRule>[
          StyleRule(
            selector: Selector.className(className),
            styles: restingStyles,
          ),
          StyleRule(
            selector: Selector('.$className:hover'),
            styles: hoveredStyles,
          ),
        ],
      ),
      div(children, classes: className, events: listeners),
    ]);
  }
}

/// Maps the interaction callbacks of [box] to DOM event listeners.
///
/// The listeners are omitted entirely for a non interactive box, so a static
/// tree renders without any JavaScript.
Map<String, EventCallback> _buildEvents(core.Box box) {
  final core.TapCallback? onTap = box.onTap;
  final core.HoverCallback? onHover = box.onHover;
  final core.LongPressCallback? onLongPress = box.onLongPress;
  final Map<String, EventCallback> events = <String, EventCallback>{};

  if (onTap == null && onHover == null && onLongPress == null) {
    return events;
  }

  var longPressed = false;
  Timer? pressTimer;

  void cancelPress() {
    pressTimer?.cancel();
    pressTimer = null;
  }

  if (onTap != null) {
    events['click'] = (event) {
      if (longPressed) {
        longPressed = false;
        return;
      }
      onTap();
    };
  }

  if (onHover != null) {
    events['mouseenter'] = (event) => onHover(true);
    events['mouseleave'] = (event) => onHover(false);
  }

  if (onLongPress != null) {
    events['pointerdown'] = (event) {
      cancelPress();
      pressTimer = Timer(_longPressDuration, () {
        pressTimer = null;
        longPressed = true;
        onLongPress();
      });
    };
    events['pointerup'] = (event) => cancelPress();
    events['pointerleave'] = (event) => cancelPress();
    events['pointercancel'] = (event) => cancelPress();
  }

  return events;
}

/// Derives a stable class name suffix from the styles it scopes.
///
/// FNV-1a is used because it is tiny, deterministic and dependency free, so the
/// server and the client agree on the class name without any coordination.
String _hashOfStyles(Styles restingStyles, Styles hoveredStyles) {
  final String seed =
      '${_serializeStyles(restingStyles)}|${_serializeStyles(hoveredStyles)}';
  var hash = 0x811C9DC5;
  for (final int codeUnit in seed.codeUnits) {
    hash = ((hash ^ codeUnit) * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

/// Flattens [styles] into a stable `property:value;` string.
String _serializeStyles(Styles styles) {
  return styles.properties.entries
      .map((MapEntry<String, String> entry) => '${entry.key}:${entry.value}')
      .join(';');
}
