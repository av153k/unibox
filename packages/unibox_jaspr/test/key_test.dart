import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_jaspr/unibox_jaspr.dart';

import 'support/harness.dart';

void main() {
  group('UINode.key', () {
    // The key sits on the renderer of the node, not on what `renderJaspr`
    // returns: that is a fragment carrying the typography rule of the model as
    // well, and a key on it would describe the tree rather than the node.
    test('keys the renderer of every node type', () {
      expect(
        renderNode(const core.Box(key: 'box')).key,
        const ValueKey<Object>('box'),
      );
      expect(
        renderNode(const core.TextNode('Hello', key: 'text')).key,
        const ValueKey<Object>('text'),
      );
      expect(
        renderNode(const core.ImageNode('logo.png', key: 'image')).key,
        const ValueKey<Object>('image'),
      );
      expect(
        renderNode(
          const core.LinkNode(
            'https://unibox.dev',
            key: 'link',
            child: core.TextNode('Unibox'),
          ),
        ).key,
        const ValueKey<Object>('link'),
      );
      expect(
        renderNode(const core.StackNode(key: 'stack')).key,
        const ValueKey<Object>('stack'),
      );
      expect(
        renderNode(const core.TextInputNode(key: 'input')).key,
        const ValueKey<Object>('input'),
      );
    });

    test('leaves an unkeyed node unkeyed', () {
      expect(renderNode(const core.TextNode('Hello')).key, isNull);
    });

    testComponents('keys the rendered elements', (tester) async {
      pumpNode(
        tester,
        const core.Box(
          key: 'root',
          children: <core.UINode>[core.TextNode('Hello', key: 'greeting')],
        ),
      );

      expect(find.byKey(const ValueKey<Object>('root')), findsOneComponent);
      expect(find.byKey(const ValueKey<Object>('greeting')), findsOneComponent);
    });

    testComponents('keys a positioned stack child', (tester) async {
      pumpNode(
        tester,
        const core.StackNode(
          width: 100,
          height: 100,
          children: <core.UINode>[
            core.PositionedNode(
              key: 'badge',
              top: 4,
              left: 4,
              child: core.TextNode('1'),
            ),
          ],
        ),
      );

      expect(find.byKey(const ValueKey<Object>('badge')), findsOneComponent);
    });

    testComponents('keeps the text of a reordered input attached to it', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.Box(
          direction: core.Axis.vertical,
          children: <core.UINode>[
            core.TextInputNode(key: 'email', value: 'ada@example.com'),
            core.TextInputNode(key: 'name', value: 'Ada'),
          ],
        ),
      );

      final Finder emailField = find.descendant(
        of: find.byKey(const ValueKey<Object>('email')),
        matching: find.tag('input'),
      );

      expect(elementOf(emailField).attributes?['value'], 'ada@example.com');
    });
  });
}
