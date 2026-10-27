/// The pages of the Unibox example.
///
/// The trees are plain Dart: the same [buildExamplePage] description renders as
/// Flutter widgets in `unibox_example_flutter` and as HTML/CSS in
/// `unibox_example_jaspr`.
///
/// The example has two pages behind one navigation bar — a signup card and a
/// list of apartments — and both hosts keep the open page in their own state,
/// exactly like they keep the values of the form.
library;

export 'src/apartments.dart';
export 'src/page.dart';
export 'src/signup_card.dart';
export 'src/theme.dart';
