import 'package:unibox_core/unibox_core.dart';

import 'material_palette.dart';
import 'material_typography.dart';

/// A labelled, filled Material 3 text field, built from a [Box] around a
/// [TextInputNode].
///
/// ```dart
/// MaterialTextField(
///   label: "Email",
///   value: state.email,
///   onChanged: store.setEmail,
///   invalid: state.emailInvalid,
///   message: state.emailInvalid ? "Enter an address with an @" : null,
/// )
/// ```
///
/// The field is a box and the value is the core input node, so both targets draw
/// it with what they already have: a `TextField` on Flutter and an `<input>` or
/// `<textarea>` on the web. The caret, the selection, the IME and autofill are the
/// platform's, because the input node delegates them.
///
/// **The fill is drawn by the box, the padding by the input.** The box states the
/// surface, the radius and the bottom line; [TextInputNode.padding] states the
/// space inside the control, so a press anywhere in the field focuses it. Padding
/// on the box would sit outside the control's hit area on both targets — the
/// difference between a field that feels like a field and one that only responds on
/// its text line.
///
/// **Filled, not outlined.** Material's outlined field floats its label into a notch
/// cut in the border, and a uniform `BoxBorder` cannot be cut; the filled variant
/// needs only a surface, a radius and a bottom line, and the line is a shadow with no
/// blur because a border cannot be one-sided. The label sits inside the fill and
/// turns primary on focus, like Material's resting filled field; floating it onto
/// the line is an animation the model has no triggered timeline for.
///
/// Every colour is a role, so a dark scheme is the host's theme rather than a
/// parameter here (see [MaterialColorRole]).
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
         gap: 4,
         children: <UINode>[
           Box(
             minHeight: 56,
             backgroundColor: const BoxColor.role(
               MaterialColorRole.surfaceContainerHighest,
             ),
             borderRadius: borderRadius,
             opacity: enabled ? null : 0.38,
             shadow: _line(focused: focused, invalid: invalid),
             textStyle: _valueStyle(),
             hoverStyle: enabled && !focused && !invalid
                 ? const BoxStyle(
                     shadow: BoxShadow(
                       color: BoxColor.role(MaterialColorRole.onSurface),
                       offsetY: 1,
                       blurRadius: 0,
                     ),
                   )
                 : null,
             children: <UINode>[
               if (label != null)
                 Box(
                   padding: const BoxSpacing.only(left: 16, right: 16, top: 8),
                   children: <UINode>[
                     TextNode(
                       label,
                       style: _labelStyle(invalid: invalid, focused: focused),
                     ),
                   ],
                 ),
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
                 padding: const BoxSpacing.only(
                   left: 16,
                   right: 16,
                   top: 4,
                   bottom: 10,
                 ),
                 onChanged: onChanged,
                 onSubmitted: onSubmitted,
                 onFocusChanged: onFocusChanged,
               ),
             ],
           ),
           if (message != null)
             Box(
               padding: const BoxSpacing.only(left: 16, right: 16),
               children: <UINode>[
                 TextNode(message, style: _labelStyle(invalid: invalid)),
               ],
             ),
         ],
       );

  /// The bottom line: two pixels of primary while focused, one otherwise, and the
  /// error colour whenever the field is invalid.
  ///
  /// A shadow with no blur, because `BoxBorder` draws all four sides and a filled
  /// field has no side borders.
  static BoxShadow _line({required bool focused, required bool invalid}) {
    return BoxShadow(
      color: invalid
          ? const BoxColor.role(MaterialColorRole.error)
          : focused
          ? const BoxColor.role(MaterialColorRole.primary)
          : const BoxColor.role(MaterialColorRole.onSurfaceVariant),
      offsetY: focused ? 2 : 1,
      blurRadius: 0,
    );
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
