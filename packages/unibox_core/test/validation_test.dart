import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

void main() {
  group('validateTree', () {
    test('accepts a well formed tree', () {
      const Box tree = Box(
        direction: Axis.vertical,
        overflow: Overflow.scroll,
        children: <UINode>[
          TextNode('Hello'),
          LinkNode('https://unibox.dev', child: TextNode('Unibox')),
          StackNode(
            children: <UINode>[
              PositionedNode(top: 0, left: 0, child: TextNode('badge')),
            ],
          ),
          Box(children: <UINode>[TextInputNode(placeholder: 'Email')]),
        ],
      );

      expect(validateTree(tree), isEmpty);
    });

    test('accepts a list item inside a list', () {
      const Box tree = Box(
        semantics: BoxSemantics(element: BoxElement.ul),
        children: <UINode>[
          Box(
            semantics: BoxSemantics(element: BoxElement.li),
            children: <UINode>[TextNode('One')],
          ),
        ],
      );

      expect(validateTree(tree), isEmpty);
    });

    test('reports a list item outside a list', () {
      const Box tree = Box(
        children: <UINode>[
          Box(
            semantics: BoxSemantics(element: BoxElement.li),
            children: <UINode>[TextNode('One')],
          ),
        ],
      );

      final TreeIssue issue = validateTree(tree).single;

      expect(issue.severity, TreeIssueSeverity.error);
      expect(issue.message, contains('BoxElement.ul'));
      expect(issue.message, contains('invalid HTML'));
    });

    test('warns about a positioned node outside a stack', () {
      const Box tree = Box(
        children: <UINode>[PositionedNode(top: 8, child: TextNode('badge'))],
      );

      final List<TreeIssue> issues = validateTree(tree);

      expect(issues, hasLength(1));
      final TreeIssue issue = issues.single;
      expect(issue.node, isA<PositionedNode>());
      expect(issue.severity, TreeIssueSeverity.warning);
      expect(issue.isError, isFalse);
      expect(issue.message, contains('StackNode'));
      expect(issue.message, contains('Box'));
    });

    test('names the root as the parent of a lone positioned node', () {
      const PositionedNode tree = PositionedNode(
        top: 8,
        child: TextNode('badge'),
      );

      expect(validateTree(tree).single.message, contains('the root'));
    });

    test('errors on a link nested in a link', () {
      const LinkNode tree = LinkNode(
        'https://a.dev',
        child: Box(
          children: <UINode>[
            LinkNode('https://b.dev', child: TextNode('inner')),
          ],
        ),
      );

      final TreeIssue issue = validateTree(tree).single;

      expect(issue.node, isA<LinkNode>());
      expect(issue.severity, TreeIssueSeverity.error);
      expect(issue.isError, isTrue);
      expect(issue.message, contains('nested'));
    });

    test('accepts links that are siblings', () {
      const Box tree = Box(
        children: <UINode>[
          LinkNode('https://a.dev', child: TextNode('a')),
          LinkNode('https://b.dev', child: TextNode('b')),
        ],
      );

      expect(validateTree(tree), isEmpty);
    });

    test('warns about mainAlign on a box that scrolls', () {
      const Box tree = Box(
        overflow: Overflow.scroll,
        mainAlign: MainAlign.center,
        children: <UINode>[TextNode('Hello')],
      );

      final TreeIssue issue = validateTree(tree).single;

      expect(issue.node, same(tree));
      expect(issue.message, contains('mainAlign: center'));
    });

    test('accepts mainAlign start on a box that scrolls', () {
      const Box tree = Box(
        overflow: Overflow.scroll,
        mainAlign: MainAlign.start,
      );

      expect(validateTree(tree), isEmpty);
    });

    test('reads the tokens resolved from the style', () {
      const Box tree = Box(
        style: BoxStyle(
          overflow: Overflow.scroll,
          mainAlign: MainAlign.spaceBetween,
        ),
      );

      expect(validateTree(tree).single.message, contains('spaceBetween'));
    });

    test('collects the issues of every nested subtree', () {
      const Box tree = Box(
        children: <UINode>[
          Box(children: <UINode>[PositionedNode(top: 0, child: TextNode('a'))]),
          LinkNode(
            'https://a.dev',
            child: LinkNode('https://b.dev', child: TextNode('b')),
          ),
        ],
      );

      expect(
        validateTree(tree).map((TreeIssue issue) => issue.severity),
        <TreeIssueSeverity>[TreeIssueSeverity.warning, TreeIssueSeverity.error],
      );
    });

    test('describes the issue as its message', () {
      const Box tree = Box(overflow: Overflow.scroll, mainAlign: MainAlign.end);

      expect(
        validateTree(tree).single.toString(),
        validateTree(tree).single.message,
      );
    });
  });
}
