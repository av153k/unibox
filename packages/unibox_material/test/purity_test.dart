import 'dart:io';

import 'package:test/test.dart';

/// The only package `unibox_material` may depend on, besides the Dart SDK.
const _allowedPackage = 'package:unibox_core/';

/// Libraries that would tie the tokens to one platform.
const _forbiddenLibraries = <String>{'dart:ui', 'dart:html', 'dart:js_interop'};

final _directivePattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  test('unibox_material depends on the Dart SDK and unibox_core only', () {
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
      reason: 'unibox_material should expose sources.',
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
        final isCore = uri.startsWith(_allowedPackage);

        expect(
          isRelative || isSdk || isCore,
          isTrue,
          reason: '${file.path} must not use "$uri".',
        );
      }
    }
  });
}
