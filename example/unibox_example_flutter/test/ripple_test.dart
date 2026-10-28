import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_flutter/unibox_flutter.dart';

/// The ink is a layer of positioned boxes, so the suite can count it: the fill and
/// the clip are there at rest, a press adds a drop, and a drop that has finished
/// takes itself away.
void main() {
  testWidgets('leaves ink where the press landed, then takes it away', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: renderFlutter(
              RippleButton(
                label: 'Press me',
                background: const BoxColor(0xFF005AC1),
                foreground: const BoxColor(0xFFFFFFFF),
                ink: const BoxColor(0xFFFFFFFF),
                hover: const BoxColor(0x1F000000),
                radius: 20,
              ),
            ),
          ),
        ),
      ),
    );

    // The fill and the clip fill the button; nothing is in flight yet.
    final Finder layers = find.byType(Positioned);
    expect(find.text('Press me'), findsOneWidget);
    expect(layers, findsNWidgets(2));

    await tester.tapAt(tester.getTopLeft(layers.first) + const Offset(10, 10));
    await tester.pump();

    // The press reached the button the label sits in, not a layer above it.
    expect(layers, findsNWidgets(3));

    await tester.pump(rippleDuration + const Duration(milliseconds: 100));
    await tester.pump();

    expect(layers, findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
