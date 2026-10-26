import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:universal_web/web.dart' as web;

import 'render.dart';
import 'values.dart';

/// Delay after which a pressed box counts as a long press.
const Duration _longPressDuration = Duration(milliseconds: 500);

/// Renders a [core.Box] as a styled `<div>`.
///
/// A box is a CSS flex container whose `flex-direction`, `justify-content`,
/// `align-items` and `gap` mirror the `Row`/`Column` the same node renders to in
/// Flutter; a box without a direction is a column. Everything else is plain CSS:
/// `width`, `height`, `padding`, `border`, `border-radius`, `box-shadow`,
/// `overflow` and friends.
///
/// The styles of a state cannot be expressed with inline styles, since those
/// always win over a pseudo class. A box with state styles is therefore rendered
/// as a scoped `.<class>` rule plus one rule per state, emitted next to the
/// `<div>`: `:hover` inside `@media (hover: hover)`, `:focus-visible`, `:active`
/// and `[aria-disabled="true"]`. The class name is derived from the resolved
/// styles, which keeps the output deterministic and therefore identical for
/// server side rendering and client side hydration.
///
/// The semantics of the box become attributes: `role`, `aria-label`,
/// `aria-checked`, `aria-disabled` and `tabindex`, which is what makes a hand
/// drawn control a real control on the web.
class UniboxBox extends StatelessComponent {
  /// Creates a renderer for [box].
  const UniboxBox({required this.box, super.key});

  /// The node being rendered.
  final core.Box box;

  @override
  Component build(BuildContext context) {
    final List<Component> children = box.children
        .map(renderNode)
        .toList(growable: false);
    final Map<String, String>? attributes = _attributes();
    final Map<String, EventCallback>? events = _events();
    final Styles restingStyles = toBoxStyles(
      box.computedStyle,
      interactive: box.isInteractive,
    );
    final String className = 'unibox-box-${_hashOf(box, restingStyles)}';
    final List<StyleRule> stateRules = _stateRules(className);

    if (stateRules.isEmpty) {
      return div(
        children,
        styles: restingStyles,
        attributes: attributes,
        events: events,
      );
    }

    return Component.fragment(<Component>[
      Style(
        styles: <StyleRule>[
          StyleRule(
            selector: Selector.className(className),
            styles: restingStyles,
          ),
          ...stateRules,
        ],
      ),
      div(children, classes: className, attributes: attributes, events: events),
    ]);
  }

  /// The pseudo class rules of the box, in cascade order.
  ///
  /// Hover is wrapped in `@media (hover: hover)` so a touch screen cannot get
  /// stuck in a hovered look, focus uses `:focus-visible` so a pointer click
  /// never paints a focus ring, and the disabled rule matches the
  /// `aria-disabled` attribute the element already carries, so the visual and
  /// the announced state can never disagree.
  List<StyleRule> _stateRules(String className) {
    final List<StyleRule> rules = <StyleRule>[];

    final Styles? hover = _stateStyles(core.BoxState.hover);
    if (hover != null) {
      rules.add(
        StyleRule.media(
          query: MediaQuery.all(canHover: true),
          styles: <StyleRule>[
            StyleRule(selector: Selector('.$className:hover'), styles: hover),
          ],
        ),
      );
    }

    final Styles? focus = _stateStyles(core.BoxState.focus);
    if (focus != null) {
      rules.add(
        StyleRule(
          selector: Selector('.$className:focus-visible'),
          styles: focus,
        ),
      );
    }

    final Styles? pressed = _stateStyles(core.BoxState.pressed);
    if (pressed != null) {
      rules.add(
        StyleRule(selector: Selector('.$className:active'), styles: pressed),
      );
    }

    final Styles? disabled = _stateStyles(core.BoxState.disabled);
    if (disabled != null) {
      rules.add(
        StyleRule(
          selector: Selector('.$className[aria-disabled="true"]'),
          styles: disabled,
        ),
      );
    }

    return rules;
  }

  /// The CSS of [state], or `null` when the box styles nothing for it.
  ///
  /// Only the tokens of the state are emitted, so the browser layers them over
  /// the resting rule exactly like the Flutter renderer layers them over the
  /// resting style.
  Styles? _stateStyles(core.BoxState state) {
    final core.BoxStyle? style = box.stateStyle(state);
    return style == null ? null : toBoxStyles(style);
  }

  /// The accessibility attributes of the box, or `null` when it needs none.
  Map<String, String>? _attributes() {
    final core.BoxSemantics? semantics = box.semantics;
    final core.BoxRole role = semantics?.role ?? core.BoxRole.none;
    final Map<String, String> attributes = <String, String>{};
    final String? htmlRole = _htmlRole(role);
    final String? label = semantics?.label;
    final bool? checked = semantics?.checked;
    final bool isCheckable =
        role == core.BoxRole.checkbox || role == core.BoxRole.switch_;

    if (htmlRole != null) {
      attributes['role'] = htmlRole;
    }
    if (label != null) {
      attributes['aria-label'] = label;
    }
    if (isCheckable && checked != null) {
      attributes['aria-checked'] = '$checked';
    }
    if (!box.enabled) {
      attributes['aria-disabled'] = 'true';
    }
    if (box.isFocusable && box.enabled) {
      attributes['tabindex'] = '0';
    }

    return attributes.isEmpty ? null : attributes;
  }

  /// The DOM listeners of the box, or `null` when it reacts to nothing.
  ///
  /// A disabled box listens to nothing at all, and a box whose role makes it
  /// focusable also activates on Enter and Space, which is what a native button
  /// does.
  Map<String, EventCallback>? _events() {
    if (!box.enabled) {
      return null;
    }

    final Map<String, EventCallback> events = _buildEvents(box);
    final core.TapCallback? onTap = box.onTap;

    if (onTap != null && box.isFocusable) {
      var activated = false;

      events['keydown'] = (web.Event event) {
        final web.KeyboardEvent keyEvent = event as web.KeyboardEvent;

        if (activated || !_isActivationKey(keyEvent.key)) {
          return;
        }

        // Space would otherwise scroll the page instead of pressing the box.
        keyEvent.preventDefault();
        activated = true;
        onTap();
      };
      events['keyup'] = (web.Event event) {
        final web.KeyboardEvent keyEvent = event as web.KeyboardEvent;

        if (_isActivationKey(keyEvent.key)) {
          activated = false;
        }
      };
    }

    return events.isEmpty ? null : events;
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

/// Derives a stable class name suffix from [box] and its resting [restingStyles].
///
/// Every state the box styles is part of the seed, so two boxes only share a
/// class when they render identically. FNV-1a is used because it is tiny,
/// deterministic and dependency free, so the server and the client agree on the
/// class name without any coordination.
String _hashOf(core.Box box, Styles restingStyles) {
  final StringBuffer seed = StringBuffer(_serializeStyles(restingStyles));

  for (final core.BoxState state in core.BoxState.values) {
    final core.BoxStyle? style = box.stateStyle(state);
    if (style != null) {
      seed.write('|${state.name}:${_serializeStyles(toBoxStyles(style))}');
    }
  }

  var hash = 0x811C9DC5;
  for (final int codeUnit in seed.toString().codeUnits) {
    hash = ((hash ^ codeUnit) * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

/// The ARIA role of [role], or `null` for a plain container.
String? _htmlRole(core.BoxRole role) {
  return switch (role) {
    core.BoxRole.none => null,
    core.BoxRole.button => 'button',
    core.BoxRole.checkbox => 'checkbox',
    core.BoxRole.switch_ => 'switch',
    core.BoxRole.link => 'link',
    core.BoxRole.heading => 'heading',
  };
}

/// Whether [key] is a key that activates a control.
bool _isActivationKey(String key) => key == 'Enter' || key == ' ';

/// Flattens [styles] into a stable `property:value;` string.
String _serializeStyles(Styles styles) {
  return styles.properties.entries
      .map((MapEntry<String, String> entry) => '${entry.key}:${entry.value}')
      .join(';');
}
