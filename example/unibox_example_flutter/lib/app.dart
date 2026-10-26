import 'package:flutter/material.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

/// The Flutter host of the shared signup card.
///
/// Everything below the [MaterialApp] is the plain node tree of
/// `unibox_example_shared`; this widget only owns the state and feeds it back
/// into the card, which is exactly what the Jaspr app does with the same tree.
///
/// The tree contains a link, so the host has to decide what following one
/// means: the [UniboxLinkScope] is that hook, and a real application would open
/// the url with `url_launcher` instead of printing it.
class UniboxExampleApp extends StatefulWidget {
  /// Creates the example application.
  const UniboxExampleApp({super.key});

  @override
  State<UniboxExampleApp> createState() => _UniboxExampleAppState();
}

class _UniboxExampleAppState extends State<UniboxExampleApp> {
  SignupFormState _state = const SignupFormState();

  void _update(SignupFormState next) => setState(() => _state = next);

  @override
  Widget build(BuildContext context) {
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

    return MaterialApp(
      title: 'Unibox example',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: UniboxLinkScope(
          open: (String url) => debugPrint('Following $url'),
          child: page.toWidget(),
        ),
      ),
    );
  }
}
