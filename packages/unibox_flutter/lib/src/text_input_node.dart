import 'package:flutter/material.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'text_style_scope.dart';

/// Renders a [core.TextInputNode] as a Material [TextField].
///
/// The field owns a [TextEditingController] so that typing keeps working while
/// [core.TextInputNode.value] is `null`. When the node does carry a value, the
/// controller follows it: values pushed by the owner replace the field content,
/// values typed by the user are reported through
/// [core.TextInputNode.onChanged].
class UniboxTextInput extends StatefulWidget {
  /// Creates a renderer for [node].
  const UniboxTextInput({required this.node, super.key});

  /// The node being rendered.
  final core.TextInputNode node;

  @override
  State<UniboxTextInput> createState() => _UniboxTextInputState();
}

class _UniboxTextInputState extends State<UniboxTextInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.node.value ?? '',
  );

  @override
  void didUpdateWidget(UniboxTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    final String? value = widget.node.value;
    if (value != null && value != _controller.text) {
      // The owner replaced the value, so move the caret to the end of it.
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final core.TextInputNode node = widget.node;
    final bool multiline = node.multiline;

    // A box that sets typography is a deliberate decision, so the field adopts
    // the ambient text style. Without a box in charge, Material's input style
    // stays in place, which is what a plain `TextField` would do.
    final bool inheritsTypography =
        UniboxTextStyleScope.maybeOf(context) != null;

    return TextField(
      controller: _controller,
      style: inheritsTypography ? DefaultTextStyle.of(context).style : null,
      obscureText: node.obscureText,
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      maxLines: multiline ? node.maxLines : 1,
      minLines: multiline ? 1 : null,
      onChanged: node.onChanged,
      onSubmitted: node.onSubmitted,
      decoration: InputDecoration(hintText: node.placeholder),
    );
  }
}
