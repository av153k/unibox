import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

void main() {
  group('TextNode', () {
    testComponents('renders a span containing the text', (tester) async {
      pumpNode(tester, const core.TextNode('Hello Unibox'));

      expect(find.tag('span'), findsOneComponent);
      expect(find.text('Hello Unibox'), findsOneComponent);
    });

    testComponents('omits styles for unset tokens', (tester) async {
      pumpNode(tester, const core.TextNode('Hello'));

      expect(stylesOf(find.tag('span')), isEmpty);
    });

    testComponents('maps typography tokens', (tester) async {
      pumpNode(
        tester,
        const core.TextNode(
          'Hello',
          fontSize: 18,
          fontWeight: core.FontWeight.semiBold,
          color: core.BoxColor(0xFF112233),
        ),
      );

      expect(stylesOf(find.tag('span')), <String, String>{
        'color': '#112233',
        'font-size': '18px',
        'font-weight': '600',
      });
    });

    testComponents('maps every font weight', (tester) async {
      const Map<core.FontWeight, String> weights = {
        core.FontWeight.normal: '400',
        core.FontWeight.medium: '500',
        core.FontWeight.semiBold: '600',
        core.FontWeight.bold: '700',
      };

      for (final MapEntry<core.FontWeight, String> entry in weights.entries) {
        pumpNode(tester, core.TextNode('Hello', fontWeight: entry.key));

        expect(stylesOf(find.tag('span'))['font-weight'], entry.value);
      }
    });

    testComponents('maps every text alignment', (tester) async {
      const Map<core.TextAlign, String> aligns = {
        core.TextAlign.left: 'left',
        core.TextAlign.center: 'center',
        core.TextAlign.right: 'right',
        core.TextAlign.justify: 'justify',
      };

      for (final MapEntry<core.TextAlign, String> entry in aligns.entries) {
        pumpNode(tester, core.TextNode('Hello', textAlign: entry.key));

        expect(stylesOf(find.tag('span'))['text-align'], entry.value);
      }
    });

    testComponents('clamps text to maxLines', (tester) async {
      pumpNode(tester, const core.TextNode('Hello', maxLines: 2));

      expect(stylesOf(find.tag('span')), <String, String>{
        'display': '-webkit-box',
        '-webkit-box-orient': 'vertical',
        '-webkit-line-clamp': '2',
        'overflow': 'hidden',
      });
    });

    testComponents('clips instead of ellipsizing a clamped block', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.TextNode(
          'Hello',
          maxLines: 3,
          overflow: core.TextOverflow.clip,
        ),
      );

      final Map<String, String> styles = stylesOf(find.tag('span'));

      expect(styles['-webkit-line-clamp'], '3');
      expect(styles['text-overflow'], 'clip');
    });

    testComponents('ellipsizes a single line without maxLines', (tester) async {
      pumpNode(
        tester,
        const core.TextNode('Hello', overflow: core.TextOverflow.ellipsis),
      );

      expect(stylesOf(find.tag('span')), <String, String>{
        'overflow': 'hidden',
        'text-overflow': 'ellipsis',
        'white-space': 'nowrap',
      });
    });

    testComponents('clips the overflow without maxLines', (tester) async {
      pumpNode(
        tester,
        const core.TextNode('Hello', overflow: core.TextOverflow.clip),
      );

      expect(stylesOf(find.tag('span')), <String, String>{
        'overflow': 'hidden',
        'text-overflow': 'clip',
      });
    });

    testComponents('renders inside a box next to other children', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          direction: core.Axis.horizontal,
          gap: 8,
          children: [core.TextNode('First'), core.TextNode('Second')],
        ),
      );

      expect(find.tag('div'), findsOneComponent);
      expect(find.tag('span'), findsNComponents(2));
      expect(find.text('First'), findsOneComponent);
    });
  });
}
