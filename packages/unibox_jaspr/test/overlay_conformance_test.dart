import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_testing/unibox_testing.dart';

import 'support/harness.dart';

/// The presentation this renderer gave the root overlay, read out of the CSS it
/// emitted.
OverlayAppearance appearanceOf() {
  final Map<String, String> layer = stylesOf(find.tag('div').first);
  final Map<String, String> barrier = stylesOf(find.tag('div').at(1));

  return OverlayAppearance(
    barrierColor: colorOf(barrier['background-color']!),
    alignment: switch (layer['align-items']) {
      'flex-start' => core.OverlayAlignment.top,
      'flex-end' => core.OverlayAlignment.bottom,
      _ => core.OverlayAlignment.center,
    },
  );
}

/// Reads a CSS colour the renderer wrote back into a [core.BoxColor].
core.BoxColor colorOf(String value) {
  if (value.startsWith('#')) {
    return core.BoxColor(0xFF000000 | int.parse(value.substring(1), radix: 16));
  }

  final RegExpMatch match = RegExp(r'rgba\((\d+), (\d+), (\d+), ([0-9.]+)\)')
      .firstMatch(value)!;

  return core.BoxColor.rgba(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
    (double.parse(match.group(4)!) * 255).round(),
  );
}

void main() {
  for (final OverlayCase overlayCase in overlayCases) {
    testComponents(overlayCase.description, (tester) async {
      pumpNode(tester, overlayCase.node);

      expect(
        appearanceOf().differencesFrom(overlayCase.expected),
        isEmpty,
        reason: overlayCase.description,
      );
    });
  }
}
