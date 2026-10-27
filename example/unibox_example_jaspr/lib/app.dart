import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_jaspr/unibox_jaspr.dart';

import 'wide_only.dart';

/// The Jaspr host of the shared example pages.
///
/// The tree below is the same `buildExamplePage(...)` call the Flutter app makes;
/// only the state container differs: a [StatefulComponent] here, a
/// `StatefulWidget` there. Both keep the values of the form and the page that is
/// open, and both hand the tree a page and a `onNavigate` callback.
///
/// The one asymmetry is the map, and it comes from the medium rather than from
/// the model: the Flutter host can measure its surface before it builds, while a
/// static render runs before a viewport exists. So the web host always passes the
/// panel and wraps it in [WideOnly], and CSS decides whether it is displayed.
class UniboxExampleApp extends StatefulComponent {
  /// Creates the example application.
  ///
  /// [initialState] and [initialPage] are what the app starts with, which keeps
  /// the component easy to render in tests, in the static export and in
  /// [buildExamplePage] previews.
  const UniboxExampleApp({
    this.initialState = const SignupFormState(),
    this.initialPage = ExamplePage.signup,
    super.key,
  });

  /// The state the form starts with.
  final SignupFormState initialState;

  /// The page that is open on the first render.
  final ExamplePage initialPage;

  @override
  State<UniboxExampleApp> createState() => UniboxExampleAppState();
}

/// The state of [UniboxExampleApp].
class UniboxExampleAppState extends State<UniboxExampleApp> {
  late SignupFormState _state = component.initialState;
  late ExamplePage _page = component.initialPage;

  void _update(SignupFormState next) => setState(() => _state = next);

  void _navigate(ExamplePage page) => setState(() => _page = page);

  core.UINode _currentPage() {
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
        map: ComponentNode(WideOnly(child: buildExampleMap().toComponent())),
      ),
    };
  }

  @override
  Component build(BuildContext context) {
    final core.Box page = buildExamplePage(
      current: _page,
      onNavigate: _navigate,
      page: _currentPage(),
    );

    return page.toComponent();
  }
}
