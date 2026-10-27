import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

void main() {
  group('StackNode', () {
    testComponents('renders a relative grid', (tester) async {
      pumpNode(tester, const core.StackNode());

      expect(find.tag('div'), findsOneComponent);
      expect(stylesOf(find.tag('div')), <String, String>{
        'position': 'relative',
        'display': 'grid',
      });
    });

    testComponents('maps dimensions to css units', (tester) async {
      pumpNode(
        tester,
        const core.StackNode(width: 200, height: double.infinity),
      );

      final Map<String, String> styles = stylesOf(find.tag('div'));

      expect(styles['width'], '200px');
      expect(styles['height'], '100%');
    });

    testComponents('layers unpositioned children in one cell', (tester) async {
      pumpNode(
        tester,
        const core.StackNode(
          width: 100,
          height: 100,
          children: [core.TextNode('Bottom'), core.TextNode('Top')],
        ),
      );

      // One container plus one cell wrapper per child.
      expect(find.tag('div'), findsNComponents(3));
      // `place-self: start` keeps a child its own size: a grid item stretches to
      // fill its cell by default, while a Flutter `Stack` lays it out at its
      // natural size in the top start corner.
      expect(stylesOf(find.tag('div').at(1)), <String, String>{
        'grid-area': '1 / 1',
        'place-self': 'start',
      });
      expect(stylesOf(find.tag('div').at(2)), <String, String>{
        'grid-area': '1 / 1',
        'place-self': 'start',
      });
      expect(find.text('Bottom'), findsOneComponent);
      expect(find.text('Top'), findsOneComponent);
    });

    testComponents('positions a child absolutely', (tester) async {
      pumpNode(
        tester,
        const core.StackNode(
          width: 100,
          height: 100,
          children: [
            core.PositionedNode(
              top: 10,
              left: 4,
              child: core.Box(width: 20, height: 20),
            ),
          ],
        ),
      );

      final Map<String, String> styles = stylesOf(find.tag('div').at(1));

      expect(styles['position'], 'absolute');
      expect(styles['top'], '10px');
      expect(styles['left'], '4px');
      expect(styles.containsKey('grid-area'), isFalse);
    });

    testComponents('positions a child from the opposite edges', (tester) async {
      pumpNode(
        tester,
        const core.StackNode(
          width: 100,
          height: 100,
          children: [
            core.PositionedNode(
              right: 8,
              bottom: 12,
              child: core.TextNode('Badge'),
            ),
          ],
        ),
      );

      final Map<String, String> styles = stylesOf(find.tag('div').at(1));

      expect(styles['position'], 'absolute');
      expect(styles['right'], '8px');
      expect(styles['bottom'], '12px');
      expect(styles.containsKey('top'), isFalse);
    });

    testComponents('keeps a positioned node without offsets in the cell', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.StackNode(
          children: [core.PositionedNode(child: core.TextNode('Centered'))],
        ),
      );

      expect(stylesOf(find.tag('div').at(1)), <String, String>{
        'grid-area': '1 / 1',
        'place-self': 'start',
      });
    });

    testComponents('nests further nodes', (tester) async {
      pumpNode(
        tester,
        const core.StackNode(
          width: 120,
          height: 120,
          children: [
            core.ImageNode('assets/cover.png', width: 120, height: 120),
            core.PositionedNode(
              left: 8,
              bottom: 8,
              child: core.TextNode('Caption'),
            ),
          ],
        ),
      );

      expect(find.tag('img'), findsOneComponent);
      expect(find.tag('span'), findsOneComponent);
      expect(find.text('Caption'), findsOneComponent);
    });
  });

  group('PositionedNode', () {
    testComponents('renders only its child without a stack', (tester) async {
      pumpNode(
        tester,
        const core.PositionedNode(top: 4, child: core.TextNode('Loose')),
      );

      expect(find.tag('div'), findsNothing);
      expect(find.tag('span'), findsOneComponent);
      expect(find.text('Loose'), findsOneComponent);
    });
  });
}
