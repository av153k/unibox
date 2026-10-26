import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

void main() {
  group('ImageNode', () {
    testComponents('renders an img with the source and an empty alt', (
      tester,
    ) async {
      pumpNode(tester, const core.ImageNode('https://example.com/a.png'));

      expect(find.tag('img'), findsOneComponent);
      expect(attributesOf(find.tag('img')), <String, String>{
        'src': 'https://example.com/a.png',
        'alt': '',
      });
      expect(stylesOf(find.tag('img')), <String, String>{
        'display': 'block',
      });
    });

    testComponents('sets the alt text', (tester) async {
      pumpNode(
        tester,
        const core.ImageNode('assets/logo.png', alt: 'Unibox logo'),
      );

      expect(attributesOf(find.tag('img'))['alt'], 'Unibox logo');
    });

    testComponents('maps dimensions to css units', (tester) async {
      pumpNode(
        tester,
        const core.ImageNode(
          'assets/logo.png',
          width: 200,
          height: double.infinity,
        ),
      );

      final Map<String, String> styles = stylesOf(find.tag('img'));

      expect(styles['width'], '200px');
      expect(styles['height'], '100%');
    });

    testComponents('maps every image fit to object-fit', (tester) async {
      const Map<core.ImageFit, String> fits = {
        core.ImageFit.cover: 'cover',
        core.ImageFit.contain: 'contain',
        core.ImageFit.fill: 'fill',
      };

      for (final MapEntry<core.ImageFit, String> entry in fits.entries) {
        pumpNode(
          tester,
          core.ImageNode('assets/logo.png', fit: entry.key),
        );

        expect(stylesOf(find.tag('img'))['object-fit'], entry.value);
      }
    });

    testComponents('maps the corner radius', (tester) async {
      pumpNode(
        tester,
        const core.ImageNode(
          'assets/logo.png',
          width: 64,
          height: 64,
          borderRadius: 8,
        ),
      );

      final Map<String, String> styles = stylesOf(find.tag('img'));

      expect(styles['border-radius'], '8px');
      expect(styles['object-fit'], isNull);
    });

    testComponents('renders inside a box next to text', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          direction: core.Axis.horizontal,
          gap: 8,
          children: [
            core.ImageNode('assets/logo.png', width: 32, height: 32),
            core.TextNode('Unibox'),
          ],
        ),
      );

      expect(find.tag('div'), findsOneComponent);
      expect(find.tag('img'), findsOneComponent);
      expect(find.tag('span'), findsOneComponent);
    });
  });
}
