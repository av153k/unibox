import 'package:unibox_core/unibox_core.dart';

import 'theme.dart';

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

/// Centers the signup card on the space the navigation leaves.
///
/// The page takes the room the frame gives it (`flex: 1`) instead of the whole
/// surface, because the navigation bar above it is part of the page frame now:
/// the card is centred in what is left, which is what both hosts show.
Box buildSignupPage({
  required SignupFormState state,
  required TextChangedCallback onNameChanged,
  required TextChangedCallback onEmailChanged,
  required TapCallback onNewsletterToggled,
  required TapCallback onSubmit,
}) {
  return Box(
    flex: 1,
    direction: Axis.vertical,
    mainAlign: MainAlign.center,
    crossAlign: CrossAlign.center,
    width: double.infinity,
    padding: const BoxSpacing.all(24),
    // The page box is what the page is about, so it is the `<main>` landmark.
    semantics: const BoxSemantics(element: BoxElement.main),
    children: <UINode>[
      buildSignupCard(
        state: state,
        onNameChanged: onNameChanged,
        onEmailChanged: onEmailChanged,
        onNewsletterToggled: onNewsletterToggled,
        onSubmit: onSubmit,
      ),
    ],
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
    // The card is a self contained composition, which is what an `<article>` is:
    // it makes sense on its own, next to anything else on the page.
    semantics: const BoxSemantics(element: BoxElement.article),
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
      _field(
        TextInputNode(
          value: state.name,
          placeholder: 'Ada Lovelace',
          onChanged: onNameChanged,
          onSubmitted: (_) => onSubmit(),
        ),
      ),
      _field(
        TextInputNode(
          value: state.email,
          placeholder: 'ada@example.com',
          onChanged: onEmailChanged,
          onSubmitted: (_) => onSubmit(),
        ),
      ),
      _newsletterRow(state, onNewsletterToggled),
      _footer(state, onSubmit),
      ?status,
    ],
  );
}

/// A text field of the form.
///
/// The node only says what the field is for, so the box around it says what the
/// field looks like: both renderers keep the platform field free of its own
/// chrome — no Material underline, no browser border and padding — which makes
/// this box the only thing that draws a field, on either target.
UINode _field(TextInputNode node) {
  return Box(
    padding: const BoxSpacing.symmetric(horizontal: 12, vertical: 10),
    backgroundColor: ExamplePalette.surface,
    borderRadius: 10,
    border: const BoxBorder(color: ExamplePalette.border),
    children: <UINode>[node],
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
///
/// The title is a level one heading: the web renders an `<h1>` and Flutter marks
/// the text as a header, which is the outline a crawler and a screen reader build
/// the page from. The line under it stays plain text.
UINode _heading() {
  return const Box(
    direction: Axis.vertical,
    gap: 4,
    textStyle: ExampleType.title,
    children: <UINode>[
      TextNode('Join Unibox', headingLevel: 1),
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
      // A live region, so a screen reader announces the confirmation when it
      // appears instead of leaving the reader to go looking for it.
      semantics: const BoxSemantics(liveRegion: true),
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
