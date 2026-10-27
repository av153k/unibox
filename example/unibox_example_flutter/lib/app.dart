import 'package:flutter/material.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

/// The Flutter host of the shared example pages.
///
/// Everything below the [MaterialApp] is the plain node tree of
/// `unibox_example_shared`; this widget only owns the state and feeds it back
/// into the tree, which is exactly what the Jaspr app does with the same tree:
/// the values of the form and the page that is open.
///
/// The tree contains a link, so the host has to decide what following one
/// means: the [FlutterLinkScope] is that hook, and a real application would open
/// the url with `url_launcher` instead of printing it.
///
/// The map on the apartments page is the host's answer to a question the tree
/// cannot ask — is the surface wide enough? — so it is measured here, with the
/// same breakpoint the web host gives to CSS. The Flutter page therefore simply
/// leaves the panel out, while the web page hides it, and both end up with one
/// column of listings on a narrow surface.
class UniboxExampleApp extends StatefulWidget {
  /// Creates the example application.
  const UniboxExampleApp({super.key});

  @override
  State<UniboxExampleApp> createState() => _UniboxExampleAppState();
}

class _UniboxExampleAppState extends State<UniboxExampleApp> {
  SignupFormState _state = const SignupFormState();
  ExamplePage _page = ExamplePage.signup;

  void _update(SignupFormState next) => setState(() => _state = next);

  void _navigate(ExamplePage page) => setState(() => _page = page);

  /// Whether [context] is drawn on a surface that can hold the map.
  ///
  /// The window is the surface the tree is given: a `Scaffold` body is as wide as
  /// it, so its width is the number the web host asks CSS about. The `Builder`
  /// below puts this lookup under the [MaterialApp], which is what installs the
  /// [MediaQuery] in the first place.
  bool _isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ExampleLayout.wideBreakpoint;

  core.UINode _currentPage(BuildContext context) {
    return switch (_page) {
      ExamplePage.signup => buildSignupPage(
        state: _state,
        onNameChanged: (String name) =>
            _update(_state.copyWith(name: name, submitted: false)),
        onEmailChanged: (String email) =>
            _update(_state.copyWith(email: email, submitted: false)),
        onNewsletterToggled: () =>
            _update(_state.copyWith(newsletter: !_state.newsletter)),
        onSubmit: () => _update(submitSignupForm(_state)),
      ),
      ExamplePage.apartments => buildApartmentsPage(
        map: _isWide(context) ? buildExampleMap() : null,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unibox example',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => FlutterLinkScope(
            open: (String url) => debugPrint('Following $url'),
            child: buildExamplePage(
              current: _page,
              onNavigate: _navigate,
              page: _currentPage(context),
            ).toWidget(),
          ),
        ),
      ),
    );
  }
}
