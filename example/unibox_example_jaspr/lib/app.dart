import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_jaspr/unibox_jaspr.dart';

/// The Jaspr host of the shared signup card.
///
/// The tree below is the same `buildExamplePage(buildSignupCard(...))` call the
/// Flutter app makes; only the state container differs: a [StatefulComponent]
/// here, a `StatefulWidget` there.
class UniboxExampleApp extends StatefulComponent {
  /// Creates the example application.
  ///
  /// [initialState] is what the form starts with, which keeps the component
  /// easy to render in tests and in [buildExamplePage] previews.
  const UniboxExampleApp({
    this.initialState = const SignupFormState(),
    super.key,
  });

  /// The state the form starts with.
  final SignupFormState initialState;

  @override
  State<UniboxExampleApp> createState() => UniboxExampleAppState();
}

/// The state of [UniboxExampleApp].
class UniboxExampleAppState extends State<UniboxExampleApp> {
  late SignupFormState _state = component.initialState;

  void _update(SignupFormState next) => setState(() => _state = next);

  @override
  Component build(BuildContext context) {
    final core.Box page = buildExamplePage(
      buildSignupCard(
        state: _state,
        onNameChanged: (String name) =>
            _update(_state.copyWith(name: name, submitted: false)),
        onEmailChanged: (String email) =>
            _update(_state.copyWith(email: email, submitted: false)),
        onNewsletterToggled: () =>
            _update(_state.copyWith(newsletter: !_state.newsletter)),
        onSubmit: () => _update(submitSignupForm(_state)),
      ),
    );

    return page.toComponent();
  }
}
