import '../callbacks.dart';
import 'ui_node.dart';

/// A single line or multiline text input.
class TextInputNode extends UINode {
  /// Creates a text input node.
  const TextInputNode({
    this.value,
    this.placeholder,
    this.obscureText = false,
    this.multiline = false,
    this.maxLines,
    this.onChanged,
    this.onSubmitted,
  });

  /// The controlled value of the input.
  ///
  /// When `null` the input starts empty and is only managed by the renderer.
  final String? value;

  /// The hint shown while the input is empty.
  final String? placeholder;

  /// Whether the entered text is hidden, e.g. for passwords.
  final bool obscureText;

  /// Whether the input accepts multiple lines and renders as a text area.
  final bool multiline;

  /// The maximum number of visible lines of a [multiline] input.
  final int? maxLines;

  /// Called whenever the value of the input changes.
  final TextChangedCallback? onChanged;

  /// Called when the value of the input is submitted.
  final TextSubmittedCallback? onSubmitted;
}
