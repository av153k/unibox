import 'events.dart';

/// Called when an interactive node is tapped.
typedef TapCallback = void Function();

/// Called when an interactive node is long pressed.
typedef LongPressCallback = void Function();

/// Called when the pointer enters (`true`) or leaves (`false`) a node.
typedef HoverCallback = void Function(bool isHovered);

/// Called whenever the text of an input node changes.
typedef TextChangedCallback = void Function(String text);

/// Called when the text of an input node is submitted.
typedef TextSubmittedCallback = void Function(String text);

/// Called when a focusable node gains (`true`) or loses (`false`) focus.
typedef FocusChangedCallback = void Function(bool isFocused);

/// Called when a press lands on a node, before it is released.
///
/// The event says where the press landed inside the box and what pressed it — the
/// two facts both targets can produce exactly. [TapCallback] stays for the common
/// case, where only the activation matters.
typedef TapDownCallback = void Function(BoxTapEvent event);
