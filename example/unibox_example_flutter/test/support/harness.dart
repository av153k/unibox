import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_example_flutter/app.dart';

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

/// The name field of the card.
Finder nameField() => find.byType(TextField).first;

/// The email field of the card.
Finder emailField() => find.byType(TextField).last;
