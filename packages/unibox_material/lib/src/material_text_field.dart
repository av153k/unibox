import 'package:unibox_core/unibox_core.dart';

import 'material_palette.dart';
import 'material_typography.dart';

/// A labelled, outlined Material 3 text field, built from a [Box] around a
/// [TextInputNode].
///
/// ```dart
/// MaterialTextField(
///   label: 'Email',
///   value: state.email,
///   onChanged: store.setEmail,
///   invalid: state.emailInvalid,
///   message: state.emailInvalid ? 'Enter an address with an @' : null,
/// );
/// ```
///
/// The field is a box and the value is the core input node, so both targets draw
/// it with what they already have: a `TextField` on Flutter and an `<input>` or
/// `<textarea>` on the web. The caret, the selection, the IME and autofill are the
/// platform's, because the input node delegates them.
///
/// **What it is not.** The label sits *above* the field and the message *below* it.
/// Material floats the label onto the border once there is a value, and that is an
/// animation the model has no triggered timeline for yet. The caret and selection
/// colours are the platform's too, so a dark scheme is `theme: MaterialPalette.darkTheme`
/// at the renderer and a matching `ColorScheme` on the Flutter side, not a token this
/// node carries.
final class MaterialTextField extends Box {
  /// Creates the field, its label and its message.
  MaterialTextField({
    super.key,
    String? value,
    void Function(String value)? onChanged,
    void Function(String value)? onSubmitted,
    void Function(bool focused)? onFocusChanged,
    String? label,
    String? placeholder,
    String? message,
    bool invalid = false,
    bool focused = false,
    bool enabled = true,
    bool obscureText = false,
    bool multiline = false,
    bool required = false,
    String? description,
    int? maxLines,
    InputType inputType = InputType.text,
    double borderRadius = 4,
    super.width,
  }) : super(
         gap: 6,
         children: <UINode>[
           if (label != null)
             TextNode(
               label,
               style: _labelStyle(invalid: invalid, focused: focused),
             ),
           Box(
             textStyle: _valueStyle(),
             borderRadius: borderRadius,
             minHeight: 56,
             opacity: enabled ? null : 0.38,
             border: BoxBorder(
               width: focused ? 2 : 1,
               color: _borderColor(focused: focused, invalid: invalid),
             ),
             hoverStyle: enabled && !focused && !invalid
                 ? BoxStyle(
                     border: BoxBorder(
                       color: const BoxColor.role(MaterialColorRole.onSurface),
                     ),
                   )
                 : null,
             padding: const BoxSpacing.symmetric(horizontal: 16, vertical: 14),
             children: <UINode>[
               TextInputNode(
                 value: value,
                 placeholder: placeholder,
                 inputType: inputType,
                 obscureText: obscureText,
                 multiline: multiline,
                 maxLines: maxLines,
                 enabled: enabled,
                 required: required,
                 invalid: invalid,
                 description: description,
                 onChanged: onChanged,
                 onSubmitted: onSubmitted,
                 onFocusChanged: onFocusChanged,
               ),
             ],
           ),
           if (message != null)
             TextNode(message, style: _labelStyle(invalid: invalid)),
         ],
       );

  /// The outline: the accent while the field has focus, the error colour while it
  /// is invalid, and the palette's line otherwise.
  static BoxColor _borderColor({required bool focused, required bool invalid}) {
    if (invalid) return const BoxColor.role(MaterialColorRole.error);
    return focused
        ? const BoxColor.role(MaterialColorRole.primary)
        : const BoxColor.role(MaterialColorRole.outline);
  }

  /// The label and the message: small, and the error colour when invalid.
  static BoxTextStyle _labelStyle({
    required bool invalid,
    bool focused = false,
  }) => MaterialTypography.bodySmall.merge(
    BoxTextStyle(
      color: invalid
          ? const BoxColor.role(MaterialColorRole.error)
          : focused
          ? const BoxColor.role(MaterialColorRole.primary)
          : const BoxColor.role(MaterialColorRole.onSurfaceVariant),
    ),
  );

  /// The text the user types: the body role, in the on-surface colour.
  static BoxTextStyle _valueStyle() => MaterialTypography.bodyLarge.merge(
    BoxTextStyle(color: const BoxColor.role(MaterialColorRole.onSurface)),
  );
}
