import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

/// Holds the package to the half of the naming rule a test can check.
///
/// This file imports `unibox_core` and `unibox_material` without a prefix and
/// names what the package exports, so a re-export of the core tokens — which
/// would put `FontWeight` and `BoxTextStyle` into a file that already has them —
/// turns into a compile error here instead of in an application.
///
/// The other half is the choice of names, which no test in a pure Dart package
/// can check: no export is called `Typography` or `TextTheme`, so a host file can
/// import this package next to `flutter/material.dart` (see the README).
void main() {
  test('exports only names a core import leaves alone', () {
    const style = MaterialTypography.bodyLarge;
    const role = MaterialTypeRole.bodyLarge;

    final List<Object> exported = <Object>[
      MaterialTypography.styles,
      MaterialTypography.of(role),
      style,
      role,
    ];

    expect(exported, hasLength(4));
    expect(MaterialTypography.of(role), style);
    expect(style, isA<BoxTextStyle>());
    expect(MaterialTypeRole.values, hasLength(15));
  });
}
