import 'dart:io';

import 'package:test/test.dart';

/// Directives that are never allowed inside `unibox_core`.
///
/// The package must stay consumable from any Dart platform, so it may only use
/// SDK libraries that are available everywhere.
const _forbiddenLibraries = <String>{'dart:ui', 'dart:html', 'dart:js_interop'};

final _directivePattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  test('unibox_core only depends on the Dart SDK and itself', () {
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

    expect(dartFiles, isNotEmpty, reason: 'unibox_core should expose sources.');

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      final uris = _directivePattern
          .allMatches(source)
          .map((match) => match.group(1)!);

      for (final uri in uris) {
        final isRelative = !uri.contains(':') && !uri.startsWith('package:');
        expect(
          isRelative ||
              (uri.startsWith('dart:') && !_forbiddenLibraries.contains(uri)),
          isTrue,
          reason: '${file.path} must not use "$uri".',
        );
      }
    }
  });
}
