import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

import 'support/harness.dart';

void main() {
  group('ProgressNode', () {
    testWidgets('draws a ring of the size, stroke and colours it states', (
      tester,
    ) async {
      await pumpMaterialNode(
        tester,
        const core.ProgressNode(
          value: 0.5,
          color: core.BoxColors.blue,
          trackColor: core.BoxColors.lightGrey,
          size: 32,
          strokeWidth: 3,
          semanticsLabel: 'Uploading',
        ),
      );

      final CircularProgressIndicator indicator = tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
      expect(indicator.value, 0.5);
      expect(indicator.strokeWidth, 3);
      expect(indicator.color, Color(core.BoxColors.blue.value));
      expect(indicator.backgroundColor, Color(core.BoxColors.lightGrey.value));
      expect(indicator.semanticsLabel, 'Uploading');
      expect(tester.getSize(find.byType(FlutterProgress)), const Size(32, 32));
    });

    testWidgets('turns while the value is unknown', (tester) async {
      await pumpMaterialNode(tester, const core.ProgressNode());

      final CircularProgressIndicator indicator = tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
      expect(indicator.value, isNull);
      expect(tester.getSize(find.byType(FlutterProgress)), const Size(48, 48));

      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
