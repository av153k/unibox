import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

void _dismiss() {}

void main() {
  group('OverlayNode', () {
    test('exposes its content as its only child', () {
      const node = OverlayNode(child: TextNode('Details'));

      expect(node.children, hasLength(1));
      expect((node.children.single as TextNode).text, 'Details');
    });

    test('starts centred on a dismissible scrim of 32% black', () {
      const node = OverlayNode(child: TextNode('Details'));

      expect(node.alignment, OverlayAlignment.center);
      expect(node.barrierDismissible, isTrue);
      expect(node.barrierColor, OverlayNode.defaultBarrierColor);
      expect(node.barrierColor.opacity, closeTo(0.32, 0.01));
      expect(node.onDismiss, isNull);
    });

    test('keeps the callback and the key it is given', () {
      const node = OverlayNode(
        key: 'details',
        child: TextNode('Details'),
        onDismiss: _dismiss,
        barrierDismissible: false,
        alignment: OverlayAlignment.bottom,
      );

      expect(node.key, 'details');
      expect(node.onDismiss, _dismiss);
      expect(node.barrierDismissible, isFalse);
      expect(node.alignment, OverlayAlignment.bottom);
    });

    test('validates its content like any other subtree', () {
      const node = OverlayNode(
        onDismiss: _dismiss,
        child: PositionedNode(child: TextNode('Outside a stack')),
      );

      expect(validateTree(node), hasLength(1));
    });

    test('reports a dismissible barrier without a dismissal', () {
      const node = OverlayNode(child: TextNode('Details'));

      final issues = validateTree(node);

      expect(issues, hasLength(1));
      expect(issues.single.node, same(node));
      expect(issues.single.message, contains('onDismiss'));
    });

    test('accepts a barrier that cannot dismiss anything', () {
      const node = OverlayNode(
        barrierDismissible: false,
        child: TextNode('Details'),
      );

      expect(validateTree(node), isEmpty);
    });

    test('accepts a dismissal callback', () {
      const node = OverlayNode(onDismiss: _dismiss, child: TextNode('Details'));

      expect(validateTree(node), isEmpty);
    });
  });
}
