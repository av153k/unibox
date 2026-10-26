import '../callbacks.dart';
import '../enums.dart';
import 'ui_node.dart';

/// A single line or multiline text input.
///
/// The node describes what the field is for, not how it looks: the keyboard and
/// the validation hints follow from [inputType], the visual style is inherited
/// from the enclosing box like every other typography token.
class TextInputNode extends UINode {
  /// Creates a text input node.
  const TextInputNode({
    super.key,
    this.value,
    this.placeholder,
    this.inputType = InputType.text,
    this.obscureText = false,
    this.multiline = false,
    this.maxLines,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.semanticsLabel,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
  });

  /// The controlled value of the input.
  ///
  /// When `null` the input starts empty and is only managed by the renderer.
  final String? value;

  /// The hint shown while the input is empty.
  final String? placeholder;

  /// The kind of value the input expects.
  ///
  /// Ignored for a [multiline] input, which always accepts plain text.
  final InputType inputType;

  /// Whether the entered text is hidden, e.g. for passwords.
  final bool obscureText;

  /// Whether the input accepts multiple lines and renders as a text area.
  final bool multiline;

  /// The maximum number of visible lines of a [multiline] input.
  final int? maxLines;

  /// Whether the field accepts input.
  ///
  /// A disabled field keeps its value and its layout, is skipped by the tab
  /// order and is announced as disabled.
  final bool enabled;

  /// Whether the value can be selected and copied but not changed.
  final bool readOnly;

  /// Whether the field takes focus as soon as it is rendered.
  final bool autofocus;

  /// The text a screen reader announces for the field.
  ///
  /// A [placeholder] is only a hint and disappears once the user types, so a
  /// field that needs an accessible name should carry one.
  final String? semanticsLabel;

  /// Called whenever the value of the input changes.
  final TextChangedCallback? onChanged;

  /// Called when the value of the input is submitted.
  final TextSubmittedCallback? onSubmitted;

  /// Called when the field gains or loses focus.
  final FocusChangedCallback? onFocusChanged;
}
