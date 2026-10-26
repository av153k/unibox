import 'package:unibox_core/unibox_core.dart';

/// The palette of the example.
///
/// The colors are declared once because both renderers paint the same card:
/// Flutter translates them to a `Color`, the web renderer to a CSS color.
abstract final class ExamplePalette {
  /// The accent of the banner, the button and the checkbox.
  static const BoxColor accent = BoxColor.rgb(0x2D, 0x6C, 0xF3);

  /// The accent while the pointer is over the button.
  static const BoxColor accentHover = BoxColor.rgb(0x1D, 0x4E, 0xD8);

  /// The accent while the button is pressed.
  static const BoxColor accentPressed = BoxColor.rgb(0x16, 0x3E, 0xB0);

  /// The background of the card.
  static const BoxColor surface = BoxColor.white;

  /// The color of the page behind the card.
  static const BoxColor canvas = BoxColor.rgb(0xF3, 0xF4, 0xF6);

  /// The default text color.
  static const BoxColor text = BoxColor.rgb(0x11, 0x18, 0x27);

  /// The color of supporting text.
  static const BoxColor muted = BoxColor.rgb(0x6B, 0x72, 0x80);

  /// The color of borders, and of the button while it is not ready.
  static const BoxColor border = BoxColor.rgb(0xE5, 0xE7, 0xEB);

  /// The color of the confirmation message.
  static const BoxColor success = BoxColor.rgb(0x15, 0x80, 0x3D);

  /// The background of the confirmation message.
  static const BoxColor successSurface = BoxColor.rgb(0xEC, 0xFD, 0xF5);
}

/// The typography of the example.
///
/// Typography is the one thing a box passes down to its children, so the card
/// states it once per area and the text nodes only repeat a token they
/// override. The rendered result is identical in Flutter and on the web: a
/// `DefaultTextStyle` on one side, plain CSS inheritance on the other.
abstract final class ExampleType {
  /// The body text of the card.
  static const BoxTextStyle body = BoxTextStyle(
    fontSize: 14,
    color: ExamplePalette.text,
  );

  /// Supporting text, such as hints and the status line.
  static const BoxTextStyle muted = BoxTextStyle(
    fontSize: 13,
    color: ExamplePalette.muted,
  );

  /// The title of the card.
  static const BoxTextStyle title = BoxTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: ExamplePalette.text,
  );

  /// The label of the primary button.
  static const BoxTextStyle button = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.semiBold,
    color: ExamplePalette.surface,
  );

  /// The link under the button.
  static const BoxTextStyle link = BoxTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.medium,
    color: ExamplePalette.accent,
  );
}

/// The values entered in the signup card.
///
/// Plain data, so both hosts can keep it in whatever state container they
/// already use: a `StatefulWidget` in Flutter, a `StatefulComponent` in Jaspr.
final class SignupFormState {
  /// Creates the state of the form.
  const SignupFormState({
    this.name = '',
    this.email = '',
    this.newsletter = false,
    this.submitted = false,
  });

  /// The entered name.
  final String name;

  /// The entered email address.
  final String email;

  /// Whether the newsletter checkbox is on.
  final bool newsletter;

  /// Whether the form has been submitted.
  final bool submitted;

  /// Whether the form has been touched at all.
  bool get isDirty => name.isNotEmpty || email.isNotEmpty;

  /// Whether the entered values can be submitted.
  bool get isComplete => name.trim().isNotEmpty && email.contains('@');

  /// Returns a copy of this state with the given fields replaced.
  SignupFormState copyWith({
    String? name,
    String? email,
    bool? newsletter,
    bool? submitted,
  }) {
    return SignupFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      newsletter: newsletter ?? this.newsletter,
      submitted: submitted ?? this.submitted,
    );
  }
}

/// Applies a submission to [state].
///
/// Both hosts use this so the rule lives next to the card instead of being
/// repeated in the two applications: nothing happens until the entered values
/// are [SignupFormState.isComplete].
SignupFormState submitSignupForm(SignupFormState state) {
  return state.isComplete ? state.copyWith(submitted: true) : state;
}

/// Centers the signup card on the example canvas.
///
/// The page expands in both directions, so it fills the host surface: a
/// `Scaffold` body in Flutter, the whole viewport on the web.
Box buildExamplePage(UINode child) {
  return Box(
    direction: Axis.vertical,
    mainAlign: MainAlign.center,
    crossAlign: CrossAlign.center,
    width: double.infinity,
    height: double.infinity,
    padding: const BoxSpacing.all(24),
    backgroundColor: ExamplePalette.canvas,
    children: <UINode>[child],
  );
}

/// Builds the interactive signup card.
///
/// The card holds no state of its own and knows nothing about Flutter or the
/// DOM: the host owns a [SignupFormState] and feeds the new values back through
/// the callbacks, which is what keeps the two renderers interchangeable.
Box buildSignupCard({
  required SignupFormState state,
  required TextChangedCallback onNameChanged,
  required TextChangedCallback onEmailChanged,
  required TapCallback onNewsletterToggled,
  required TapCallback onSubmit,
}) {
  final UINode? status = _status(state);

  return Box(
    direction: Axis.vertical,
    gap: 16,
    width: 380,
    textStyle: ExampleType.body,
    padding: const BoxSpacing.all(24),
    backgroundColor: ExamplePalette.surface,
    borderRadius: 16,
    border: const BoxBorder(color: ExamplePalette.border),
    shadow: const BoxShadow(
      color: BoxColor(0x14000000),
      offsetY: 12,
      blurRadius: 32,
    ),
    children: <UINode>[
      _banner(),
      _heading(),
      TextInputNode(
        value: state.name,
        placeholder: 'Ada Lovelace',
        onChanged: onNameChanged,
        onSubmitted: (_) => onSubmit(),
      ),
      TextInputNode(
        value: state.email,
        placeholder: 'ada@example.com',
        onChanged: onEmailChanged,
        onSubmitted: (_) => onSubmit(),
      ),
      _newsletterRow(state, onNewsletterToggled),
      _footer(state, onSubmit),
      ?status,
    ],
  );
}

/// The header: a colored banner with the avatar chip sitting on its lower edge.
///
/// The stack is what layers the two: the banner is a regular child, the avatar
/// is positioned inside the same area.
UINode _banner() {
  return StackNode(
    width: double.infinity,
    height: 88,
    children: <UINode>[
      Box(
        width: double.infinity,
        height: 88,
        backgroundColor: ExamplePalette.accent,
        borderRadius: 12,
      ),
      PositionedNode(left: 16, bottom: 8, child: _avatarChip()),
    ],
  );
}

/// The initials of the member, layered over the banner.
UINode _avatarChip() {
  return Box(
    direction: Axis.horizontal,
    mainAlign: MainAlign.center,
    crossAlign: CrossAlign.center,
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: ExamplePalette.surface,
    border: const BoxBorder(width: 4, color: ExamplePalette.accent),
    textStyle: const BoxTextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: ExamplePalette.accent,
    ),
    children: <UINode>[const TextNode('AL')],
  );
}

/// The title above the fields.
///
/// The heading sets the title typography and the subtitle overrides the one
/// token it changes, which is the whole point of inheritance: no node has to
/// repeat what its box already says.
UINode _heading() {
  return const Box(
    direction: Axis.vertical,
    gap: 4,
    textStyle: ExampleType.title,
    children: <UINode>[
      TextNode('Join Unibox'),
      TextNode('One description, two renderers.', style: ExampleType.muted),
    ],
  );
}

/// The newsletter opt-in, a tappable row with a hand drawn checkbox.
///
/// The checkbox is drawn out of boxes, so before `semantics` a screen reader
/// only found a label. The role and the checked state make it a checkbox for
/// assistive technologies, and the role also puts it in the tab order.
UINode _newsletterRow(SignupFormState state, TapCallback onToggle) {
  return Box(
    direction: Axis.horizontal,
    gap: 12,
    crossAlign: CrossAlign.center,
    onTap: onToggle,
    semantics: BoxSemantics(
      role: BoxRole.checkbox,
      label: 'Release notes',
      checked: state.newsletter,
    ),
    children: <UINode>[
      Box(
        direction: Axis.horizontal,
        mainAlign: MainAlign.center,
        crossAlign: CrossAlign.center,
        width: 24,
        height: 24,
        borderRadius: 6,
        backgroundColor: state.newsletter
            ? ExamplePalette.accent
            : ExamplePalette.surface,
        border: BoxBorder(
          width: 2,
          color: state.newsletter
              ? ExamplePalette.accent
              : ExamplePalette.border,
        ),
        children: <UINode>[
          if (state.newsletter)
            const TextNode(
              '✓',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ExamplePalette.surface,
            ),
        ],
      ),
      const TextNode('Release notes'),
    ],
  );
}

/// The action area: a full width submit button and the docs link below it.
///
/// The button is a hand drawn control, so its state lives in the node: `enabled`
/// decides whether it reacts, `stateStyles` describes how it looks in every
/// state and `semantics` makes it a real button for a keyboard and a screen
/// reader. Nothing here needs a second code path per target.
UINode _footer(SignupFormState state, TapCallback onSubmit) {
  return Box(
    direction: Axis.vertical,
    gap: 12,
    children: <UINode>[
      Box(
        onTap: onSubmit,
        enabled: state.isComplete,
        direction: Axis.horizontal,
        mainAlign: MainAlign.center,
        width: double.infinity,
        padding: const BoxSpacing.symmetric(horizontal: 18, vertical: 12),
        borderRadius: 10,
        backgroundColor: ExamplePalette.accent,
        textStyle: ExampleType.button,
        stateStyles: const <BoxState, BoxStyle>{
          BoxState.hover: BoxStyle(backgroundColor: ExamplePalette.accentHover),
          BoxState.pressed: BoxStyle(
            backgroundColor: ExamplePalette.accentPressed,
          ),
          BoxState.focus: BoxStyle(
            border: BoxBorder(color: ExamplePalette.text),
          ),
          BoxState.disabled: BoxStyle(
            backgroundColor: ExamplePalette.border,
            textStyle: BoxTextStyle(color: ExamplePalette.muted),
          ),
        },
        semantics: BoxSemantics(role: BoxRole.button, label: 'Create account'),
        children: <UINode>[const TextNode('Create account')],
      ),
      const Box(
        direction: Axis.horizontal,
        mainAlign: MainAlign.center,
        textStyle: ExampleType.link,
        children: <UINode>[
          LinkNode(
            'https://unibox.dev',
            newTab: true,
            child: TextNode('Read the docs'),
          ),
        ],
      ),
    ],
  );
}

/// The line under the button: either a hint or the confirmation.
UINode? _status(SignupFormState state) {
  if (state.submitted) {
    return Box(
      padding: const BoxSpacing.all(12),
      backgroundColor: ExamplePalette.successSurface,
      borderRadius: 10,
      textStyle: const BoxTextStyle(
        fontSize: 13,
        color: ExamplePalette.success,
      ),
      children: <UINode>[
        TextNode(
          'Thanks, ${state.name.trim()}! '
          'We will write to ${state.email.trim()}.',
        ),
      ],
    );
  }
  if (!state.isDirty) {
    return null;
  }
  return TextNode(
    state.isComplete
        ? 'Looks good - press Create account.'
        : 'Add a name and an email address.',
    style: ExampleType.muted,
  );
}
