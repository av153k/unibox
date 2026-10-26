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
