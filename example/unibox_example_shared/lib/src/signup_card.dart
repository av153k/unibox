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
    children: <UINode>[
      const TextNode(
        'AL',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ExamplePalette.accent,
      ),
    ],
  );
}

/// The title above the fields.
UINode _heading() {
  return const Box(
    direction: Axis.vertical,
    gap: 4,
    children: <UINode>[
      TextNode(
        'Join Unibox',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: ExamplePalette.text,
      ),
      TextNode(
        'One description, two renderers.',
        fontSize: 14,
        color: ExamplePalette.muted,
      ),
    ],
  );
}

/// The newsletter opt-in, a tappable row with a hand drawn checkbox.
UINode _newsletterRow(SignupFormState state, TapCallback onToggle) {
  return Box(
    direction: Axis.horizontal,
    gap: 12,
    crossAlign: CrossAlign.center,
    onTap: onToggle,
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
      const TextNode('Release notes', fontSize: 14, color: ExamplePalette.text),
    ],
  );
}

/// The action area: a full width submit button and the docs link below it.
UINode _footer(SignupFormState state, TapCallback onSubmit) {
  return Box(
    direction: Axis.vertical,
    gap: 12,
    children: <UINode>[
      Box(
        onTap: onSubmit,
        direction: Axis.horizontal,
        mainAlign: MainAlign.center,
        width: double.infinity,
        padding: const BoxSpacing.symmetric(horizontal: 18, vertical: 12),
        borderRadius: 10,
        backgroundColor: state.isComplete
            ? ExamplePalette.accent
            : ExamplePalette.border,
        hoverStyle: state.isComplete
            ? const BoxStyle(backgroundColor: ExamplePalette.accentHover)
            : null,
        children: <UINode>[
          TextNode(
            'Create account',
            fontSize: 14,
            fontWeight: FontWeight.semiBold,
            color: state.isComplete
                ? ExamplePalette.surface
                : ExamplePalette.muted,
          ),
        ],
      ),
      const Box(
        direction: Axis.horizontal,
        mainAlign: MainAlign.center,
        children: <UINode>[
          LinkNode(
            'https://unibox.dev',
            newTab: true,
            child: TextNode(
              'Read the docs',
              fontSize: 14,
              fontWeight: FontWeight.medium,
              color: ExamplePalette.accent,
            ),
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
      children: <UINode>[
        TextNode(
          'Thanks, ${state.name.trim()}! '
          'We will write to ${state.email.trim()}.',
          fontSize: 13,
          color: ExamplePalette.success,
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
    fontSize: 13,
    color: ExamplePalette.muted,
  );
}
