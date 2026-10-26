import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_example_flutter/app.dart';

/// The name field of the card.
Finder nameField() => find.byType(TextField).first;

/// The email field of the card.
Finder emailField() => find.byType(TextField).last;

/// Pumps the example on a surface tall enough for the whole card.
///
/// The wide test font makes every line taller than the real font the card is
/// designed for, so the default 800x600 surface is too short.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const UniboxExampleApp());
}

/// Fills both fields with a valid name and email address.
Future<void> fillForm(WidgetTester tester) async {
  await tester.enterText(nameField(), 'Ada');
  await tester.enterText(emailField(), 'ada@example.com');
  await tester.pump();
}

void main() {
  group('UniboxExampleApp', () {
    testWidgets('renders the shared node tree', (tester) async {
      await pumpApp(tester);

      expect(find.text('Join Unibox'), findsOneWidget);
      expect(find.text('One description, two renderers.'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('ada@example.com'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Read the docs'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the entered values and reports the form as complete', (
      tester,
    ) async {
      await pumpApp(tester);

      await fillForm(tester);

      expect(tester.widget<TextField>(nameField()).controller!.text, 'Ada');
      expect(
        tester.widget<TextField>(emailField()).controller!.text,
        'ada@example.com',
      );
      expect(find.text('Looks good - press Create account.'), findsOneWidget);
    });

    testWidgets('shows the confirmation after submitting', (tester) async {
      await pumpApp(tester);
      await fillForm(tester);

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(
        find.text('Thanks, Ada! We will write to ada@example.com.'),
        findsOneWidget,
      );
    });

    testWidgets('ignores a submission while the form is incomplete', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(find.textContaining('Thanks, '), findsNothing);
      expect(find.text('Add a name and an email address.'), findsNothing);
    });

    testWidgets('submits when enter is pressed in the email field', (
      tester,
    ) async {
      await pumpApp(tester);
      await fillForm(tester);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(
        find.text('Thanks, Ada! We will write to ada@example.com.'),
        findsOneWidget,
      );
    });

    testWidgets('toggles the newsletter opt-in', (tester) async {
      await pumpApp(tester);

      expect(find.text('✓'), findsNothing);

      await tester.tap(find.text('Release notes'));
      await tester.pump();

      expect(find.text('✓'), findsOneWidget);

      await tester.tap(find.text('Release notes'));
      await tester.pump();

      expect(find.text('✓'), findsNothing);
    });
  });
}
