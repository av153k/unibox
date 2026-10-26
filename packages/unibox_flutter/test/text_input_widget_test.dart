import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The [TextField] widget rendered by the harness.
TextField renderedField(WidgetTester tester) =>
    tester.widget<TextField>(inNode(find.byType(TextField)));

/// The text currently held by the rendered field.
String currentText(WidgetTester tester) =>
    renderedField(tester).controller!.text;

void main() {
  group('TextInputNode', () {
    testWidgets('starts empty without a value', (tester) async {
      await pumpMaterialNode(tester, const core.TextInputNode());

      expect(currentText(tester), isEmpty);
    });

    testWidgets('shows the controlled value', (tester) async {
      await pumpMaterialNode(tester, const core.TextInputNode(value: 'hello'));

      expect(currentText(tester), 'hello');
    });

    testWidgets('reports changes and accepts typed text', (tester) async {
      final List<String> changes = <String>[];

      await pumpMaterialNode(
        tester,
        core.TextInputNode(onChanged: changes.add),
      );
      await tester.enterText(find.byType(TextField), 'abc');

      expect(changes, <String>['abc']);
      expect(currentText(tester), 'abc');
    });

    testWidgets('reports submission', (tester) async {
      final List<String> submissions = <String>[];

      await pumpMaterialNode(
        tester,
        core.TextInputNode(value: 'hello', onSubmitted: submissions.add),
      );
      await tester.enterText(find.byType(TextField), 'sent');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submissions, <String>['sent']);
    });

    testWidgets('follows a value pushed by the owner', (tester) async {
      await pumpMaterialNode(tester, const core.TextInputNode(value: 'one'));
      await pumpMaterialNode(tester, const core.TextInputNode(value: 'two'));

      expect(currentText(tester), 'two');
    });

    testWidgets('keeps typed text when the owner does not control it', (
      tester,
    ) async {
      await pumpMaterialNode(tester, const core.TextInputNode());
      await tester.enterText(find.byType(TextField), 'typed');
      await pumpMaterialNode(tester, const core.TextInputNode());

      expect(currentText(tester), 'typed');
    });

    testWidgets('renders the placeholder as a hint', (tester) async {
      await pumpMaterialNode(
        tester,
        const core.TextInputNode(placeholder: 'Email address'),
      );

      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('obscures the text', (tester) async {
      await pumpMaterialNode(
        tester,
        const core.TextInputNode(value: 'secret', obscureText: true),
      );

      expect(renderedField(tester).obscureText, isTrue);
    });

    testWidgets('renders a single line field by default', (tester) async {
      await pumpMaterialNode(tester, const core.TextInputNode());

      final TextField field = renderedField(tester);
      expect(field.maxLines, 1);
      expect(field.minLines, isNull);
      expect(field.keyboardType, TextInputType.text);
    });

    testWidgets('renders a multiline field', (tester) async {
      await pumpMaterialNode(
        tester,
        const core.TextInputNode(multiline: true, maxLines: 4),
      );

      final TextField field = renderedField(tester);
      expect(field.maxLines, 4);
      expect(field.minLines, 1);
      expect(field.keyboardType, TextInputType.multiline);
    });

    testWidgets('lets a multiline field grow without a maxLines', (
      tester,
    ) async {
      await pumpMaterialNode(tester, const core.TextInputNode(multiline: true));

      expect(renderedField(tester).maxLines, isNull);
    });

    testWidgets('renders inside a box next to other children', (tester) async {
      await pumpMaterialNode(
        tester,
        const core.Box(
          direction: core.Axis.vertical,
          gap: 8,
          children: [
            core.TextInputNode(placeholder: 'Name'),
            core.TextNode('Send'),
          ],
        ),
      );

      expect(inNode(find.byType(TextField)), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
    });
  });
}
