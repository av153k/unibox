import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// How many times [rule] appears in the rendered CSS.
int _ruleCount(String rule) =>
    RegExp(RegExp.escape(rule)).allMatches(allCss()).length;

void main() {
  group('the stylesheet of a rendering', () {
    testComponents('gives two boxes with one look a single class and rule', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          children: <core.UINode>[
            core.Box(backgroundColor: core.BoxColor.white),
            core.Box(backgroundColor: core.BoxColor.white),
          ],
        ),
      );

      final List<String> classes = <String>[
        for (final TestRenderElement element in elementsOf(find.tag('div')))
          if (element.classes != null) element.classes!,
      ];

      // The two children were declared apart and render alike, so they wear the
      // same class and the page states that look once.
      expect(classes[1], classes[2]);
      expect(_ruleCount('.${classes[1]} {'), 1);
    });

    testComponents('gives two different looks two classes', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          children: <core.UINode>[
            core.Box(backgroundColor: core.BoxColor.white),
            core.Box(backgroundColor: core.BoxColor.black),
          ],
        ),
      );

      final List<TestRenderElement> elements = elementsOf(find.tag('div'));

      expect(elements[1].classes, isNot(elements[2].classes));
    });

    testComponents('gives two texts with one style a single class', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          children: <core.UINode>[
            core.TextNode('One', fontSize: 13),
            core.TextNode('Two', fontSize: 13),
          ],
        ),
      );

      final List<TestRenderElement> spans = elementsOf(find.tag('span'));

      expect(spans[0].classes, isNotNull);
      expect(spans[0].classes, spans[1].classes);
      expect(_ruleCount('.${spans[0].classes} {'), 1);
    });

    testComponents('leaves no look inline on any element', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          backgroundColor: core.BoxColor.white,
          padding: core.BoxSpacing.all(16),
          children: <core.UINode>[
            core.TextNode('Unibox', fontWeight: core.FontWeight.bold),
            core.ImageNode('assets/logo.png', width: 32, height: 32),
            core.TextInputNode(placeholder: 'Email'),
            core.StackNode(children: <core.UINode>[core.TextNode('badge')]),
          ],
        ),
      );

      for (final String tag in <String>['div', 'span', 'img', 'input']) {
        for (final TestRenderElement element in elementsOf(find.tag(tag))) {
          expect(
            element.styles,
            isNull,
            reason: 'a <$tag> still carries an inline style',
          );
        }
      }

      // Everything the tree paints is in the one stylesheet instead.
      expect(allCss(), contains('background-color: #ffffff;'));
    });

    testComponents('names a class after the node it draws', (tester) async {
      pumpNode(tester, const core.TextNode('Unibox'));

      expect(
        classesOf(find.tag('span')),
        matches(RegExp(r'^unibox-text-[0-9a-f]{8}$')),
      );
    });
  });
}
