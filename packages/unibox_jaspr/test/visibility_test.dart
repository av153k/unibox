import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The declarations of the first rule for [className], which is the box's own —
/// before any container block restates it.
String _baseRule(String className) {
  final RegExpMatch? match = RegExp('\\.$className \\{([^}]*)\\}')
      .firstMatch(allCss());

  if (match == null) {
    throw StateError('No base rule for $className in:\n${allCss()}');
  }

  return match.group(1)!;
}

/// The declarations a `@container (min-width: [width])` block gives [className].
String _containerRule(String className, String width) {
  final RegExpMatch? match = RegExp(
    '@container \\(min-width: ${RegExp.escape(width)}\\) \\{[^}]*'
    '\\.$className \\{([^}]*)\\}',
  ).firstMatch(allCss());

  if (match == null) {
    throw StateError(
      'No container rule at $width for $className in:\n${allCss()}',
    );
  }

  return match.group(1)!;
}

void main() {
  group('a wide-only box', () {
    testComponents('is hidden until the container is wide enough', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          width: 800,
          children: <core.UINode>[
            core.Box(
              visibleFrom: 900,
              children: <core.UINode>[core.TextNode('map')],
            ),
          ],
        ),
      );

      final String className = classNamesOf(find.tag('div').at(1)).first;

      // Mobile first: the base rule hides it, so a browser without container
      // queries renders the narrow layout rather than a broken wide one.
      expect(_baseRule(className), contains('display: none'));
      expect(_containerRule(className, '900px'), contains('display: flex'));
    });

    testComponents('makes its parent the box it measures', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          width: 800,
          children: <core.UINode>[
            core.Box(
              visibleFrom: 900,
              children: <core.UINode>[core.TextNode('map')],
            ),
          ],
        ),
      );

      expect(stylesOf(find.tag('div').first)['container-type'], 'inline-size');
    });
  });

  group('a narrow-only box', () {
    testComponents('is taken away above its threshold', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          width: 800,
          children: <core.UINode>[
            core.Box(
              visibleUntil: 900,
              children: <core.UINode>[core.TextNode('fab')],
            ),
          ],
        ),
      );

      final String className = classNamesOf(find.tag('div').at(1)).first;

      expect(_baseRule(className), isNot(contains('display: none')));
      expect(_containerRule(className, '900px'), contains('display: none'));
    });
  });

  group('a box with no threshold', () {
    testComponents('declares no container and no query', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          width: 800,
          children: <core.UINode>[core.TextNode('nothing to hide')],
        ),
      );

      expect(
        stylesOf(find.tag('div').first),
        isNot(contains('container-type')),
      );
      expect(allCss(), isNot(contains('@container')));
    });
  });
}
