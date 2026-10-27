import 'package:unibox_core/unibox_core.dart';

import 'apartments.dart';
import 'page.dart';
import 'page_state.dart';
import 'signup_card.dart';

/// The example as one node: the bar, the listings and the sign-up dialog, drawn
/// from [ExampleState].
///
/// This is the whole application. A host renders it through the stateful renderer
/// of its target (`FlutterStateful` and `JasprStateful`) and supplies only what a
/// node cannot know — the surface, how a link opens, and whether there is room for
/// the map — which is why each host of the example is one small file.
final class ExamplePageNode extends StatefulNode<ExampleState, ExampleStore> {
  /// Creates the page, starting with [initialForm] and with the dialog open when
  /// [signupOpen] is set.
  ///
  /// [signupOpen] is for a static export: a document has no click to open the
  /// dialog, so it is rendered in the state it should start in.
  ///
  /// [panel] is the map the listings show beside them. It is passed in because
  /// the width of the surface decides whether it exists, and a node cannot ask.
  factory ExamplePageNode({
    UINode? panel,
    SignupFormState initialForm = const SignupFormState(),
    bool signupOpen = false,
    Object? key,
  }) {
    return ExamplePageNode._(
      key: key,
      panel: panel,
      create: () => ExampleStore(initial: initialForm, openSignup: signupOpen),
      view: (ExampleState state, ExampleStore store) =>
          exampleView(state: state, store: store, panel: panel),
    );
  }

  ExamplePageNode._({
    required super.create,
    required super.view,
    required this.panel,
    super.key,
  });

  /// The panel drawn beside the listings, or `null` when there is no room for it.
  final UINode? panel;
}

/// Draws [state], with [store] for the callbacks the tree hands out.
///
/// The dialog is part of the tree only while it is open: a closed dialog is
/// simply absent, so the renderer sees an ordinary page and no overlay at all.
UINode exampleView({
  required ExampleState state,
  required ExampleStore store,
  UINode? panel,
}) {
  return buildExamplePage(
    current: state.current,
    onNavigate: store.navigate,
    page: buildApartmentsPage(map: panel),
    dialog: state.signupOpen
        ? buildSignupDialog(
            state: state.form,
            onNameChanged: store.setName,
            onEmailChanged: store.setEmail,
            onNewsletterToggled: store.toggleNewsletter,
            onSubmit: store.submit,
            onDismiss: store.closeSignup,
          )
        : null,
  );
}
