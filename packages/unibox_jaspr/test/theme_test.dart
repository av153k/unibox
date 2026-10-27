import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The roles the tests share.
enum AppColor { primary, onPrimary, surfaceContainerHigh }

const core.UniboxTheme theme = core.UniboxTheme(
  colors: <AppColor, core.BoxColor>{
    AppColor.primary: core.BoxColor(0xFF6750A4),
    AppColor.onPrimary: core.BoxColor(0xFFFFFFFF),
    AppColor.surfaceContainerHigh: core.BoxColor(0xFFECE6F0),
  },
);

void main() {
  group('a colour role', () {
    testComponents('is written as the custom property of its name', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          width: 40,
          height: 40,
          backgroundColor: core.BoxColor.role(AppColor.primary),
        ),
        theme: theme,
      );

      expect(
        stylesOf(find.tag('div'))['background-color'],
        'var(--unibox-color-primary)',
      );
    });

    testComponents('is defined once, in the root of the document', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          width: 40,
          height: 40,
          backgroundColor: core.BoxColor.role(AppColor.primary),
        ),
        theme: theme,
      );

      final Map<String, String> root = declarationsOf(':root');

      expect(root['--unibox-color-primary'], '#6750a4');
      expect(root['--unibox-color-on-primary'], '#ffffff');
      expect(root['--unibox-color-surface-container-high'], '#ece6f0');
      // The typography of the model shares the selector, as CSS allows.
      expect(root['font-size'], '16px');
    });

    testComponents('is defined whether or not a node names it', (tester) async {
      pumpNode(tester, const core.Box(width: 40, height: 40), theme: theme);

      // A host stylesheet has to be able to read a role the tree leaves alone.
      expect(declarationsOf(':root').keys, contains('--unibox-color-primary'));
    });

    testComponents('resolves a text colour and a border colour', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.TextNode(
          'Unibox',
          color: core.BoxColor.role(AppColor.onPrimary),
        ),
        theme: theme,
      );

      expect(
        stylesOf(find.tag('span'))['color'],
        'var(--unibox-color-on-primary)',
      );

      pumpNode(
        tester,
        const core.Box(
          width: 40,
          height: 40,
          border: core.BoxBorder(
            width: 2,
            color: core.BoxColor.role(AppColor.primary),
          ),
        ),
        theme: theme,
      );

      final Map<String, String> styles = stylesOf(find.tag('div'));

      expect(styles['border-color'], 'var(--unibox-color-primary)');
      expect(styles['border'], contains('2px'));
    });

    testComponents('leaves a literal colour as a value', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          width: 40,
          height: 40,
          backgroundColor: core.BoxColor.white,
        ),
        theme: theme,
      );

      expect(stylesOf(find.tag('div'))['background-color'], '#ffffff');
    });

    testComponents('writes no colour variables without a theme', (
      tester,
    ) async {
      pumpNode(tester, const core.Box(width: 40, height: 40));

      // `:root` still carries the typography of the model; only the colours are
      // there when a theme is.
      expect(
        declarationsOf(':root').keys
            .where((String key) => key.startsWith('--unibox-color')),
        isEmpty,
      );
    });
  });
}
