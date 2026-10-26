import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:universal_web/web.dart' as web;

import 'values.dart';

/// Renders a [core.TextInputNode] as an `<input>` or a `<textarea>`.
///
/// A single line input becomes `<input type="text">`, an obscured one becomes
/// `<input type="password">`, and a multiline one becomes a `<textarea>` whose
/// `rows` start at [core.TextInputNode.maxLines].
///
/// A [core.TextInputNode.value] is written into the field, which makes the field
/// controlled: rendering the node again with a new value replaces what the user
/// typed. Without a value the field keeps its own content and only reports
/// changes through [core.TextInputNode.onChanged].
///
/// [core.TextInputNode.onSubmitted] fires on `Enter` for a single line field and
/// on `Ctrl`/`Cmd` + `Enter` for a text area, because a plain `Enter` inserts a
/// newline there. That is the same split a Flutter `TextField` has, where the
/// multiline keyboard type only offers a newline action.
class UniboxTextInput extends StatelessComponent {
  /// Creates a renderer for [node].
  const UniboxTextInput({required this.node, super.key});

  /// The node being rendered.
  final core.TextInputNode node;

  @override
  Component build(BuildContext context) {
    final String? placeholder = node.placeholder;

    if (node.multiline) {
      final String? value = node.value;

      return textarea(
        <Component>[if (value != null) Component.text(value)],
        placeholder: placeholder,
        rows: node.maxLines,
        styles: toTextInputStyles(),
        events: _events(),
      );
    }

    return input(
      type: node.obscureText ? InputType.password : InputType.text,
      value: node.value,
      styles: toTextInputStyles(),
      // The input component has no `placeholder` parameter, so it is passed
      // through the attribute escape hatch instead.
      attributes: placeholder == null
          ? null
          : <String, String>{'placeholder': placeholder},
      events: _events(),
    );
  }

  /// The listeners of the field, or `null` when the node reacts to nothing.
  ///
  /// The `input` event carries the text of an input or text area directly, so
  /// [core.TextInputNode.onChanged] is attached with the typed `events` helper.
  Map<String, EventCallback>? _events() {
    final core.TextChangedCallback? onChanged = node.onChanged;
    final core.TextSubmittedCallback? onSubmitted = node.onSubmitted;

    if (onChanged == null && onSubmitted == null) {
      return null;
    }

    final bool multiline = node.multiline;

    return <String, EventCallback>{
      ...events<String>(onInput: onChanged),
      if (onSubmitted != null)
        'keydown': (event) {
          if (_isSubmit(event, multiline: multiline)) {
            onSubmitted(_fieldValue(event));
          }
        },
    };
  }
}

/// Whether [event] is the key press that submits a field.
///
/// A single line field submits on a bare `Enter`; a text area needs
/// `Ctrl`/`Cmd` + `Enter` because it consumes `Enter` for its own line breaks.
///
/// The DOM types of `package:web` are extension types, which are erased at
/// runtime: a runtime `is` check would always succeed. The cast therefore only
/// tells the analyzer what the browser already guarantees — a `keydown` listener
/// of a field can only receive a keyboard event.
bool _isSubmit(web.Event event, {required bool multiline}) {
  final web.KeyboardEvent keyEvent = event as web.KeyboardEvent;

  if (keyEvent.key != 'Enter') {
    return false;
  }
  return multiline ? keyEvent.ctrlKey || keyEvent.metaKey : true;
}

/// The text currently shown by the field that emitted [event].
///
/// The listener is only attached to a single input or text area, and both expose
/// their content as `value`.
String _fieldValue(web.Event event) {
  return (event.target as web.HTMLInputElement).value;
}
