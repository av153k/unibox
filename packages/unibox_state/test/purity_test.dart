import 'dart:io';

import 'package:test/test.dart';

/// The packages `unibox_state` may depend on, besides the Dart SDK.
const _allowedPackages = <String>[
  'package:listen/',
  'package:meta/',
  'package:unibox_core/',
];

/// Libraries that would tie the store to one platform.
const _forbiddenLibraries = <String>{'dart:ui', 'dart:html', 'dart:js_interop'};

final _directivePattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  test('unibox_state depends on the SDK, unibox_core and listen only', () {
    final libDirectory = Directory('lib');
    expect(
      libDirectory.existsSync(),
      isTrue,
      reason: 'Expected a lib/ directory next to the package root.',
    );

    final dartFiles = libDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    expect(
      dartFiles,
      isNotEmpty,
      reason: 'unibox_state should expose sources.',
    );

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      final uris = _directivePattern
          .allMatches(source)
          .map((match) => match.group(1)!);

      for (final uri in uris) {
        final isRelative = !uri.contains(':') && !uri.startsWith('package:');
        final isSdk =
            uri.startsWith('dart:') && !_forbiddenLibraries.contains(uri);
        final isAllowed = _allowedPackages.any(uri.startsWith);

        expect(
          isRelative || isSdk || isAllowed,
          isTrue,
          reason: '${file.path} must not use "$uri".',
        );
      }
    }
  });
}
