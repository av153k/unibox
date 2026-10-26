import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

void main() {
  group('TextNode', () {
    test('stores its text and typography tokens', () {
      const node = TextNode(
        'Hello',
        fontSize: 18,
        fontWeight: FontWeight.semiBold,
        color: BoxColor.black,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );

      expect(node.text, 'Hello');
      expect(node.fontSize, 18);
      expect(node.fontWeight, FontWeight.semiBold);
      expect(node.color, BoxColor.black);
      expect(node.textAlign, TextAlign.center);
      expect(node.maxLines, 2);
      expect(node.overflow, TextOverflow.ellipsis);
      expect(node.children, isEmpty);
    });

    test('leaves styling unset by default', () {
      const node = TextNode('Hello');

      expect(node.fontSize, isNull);
      expect(node.fontWeight, isNull);
      expect(node.color, isNull);
      expect(node.textAlign, isNull);
      expect(node.maxLines, isNull);
      expect(node.overflow, isNull);
    });
  });

  group('ImageNode', () {
    test('defaults to decorative alt text and natural size', () {
      const node = ImageNode('https://example.com/cat.png');

      expect(node.src, 'https://example.com/cat.png');
      expect(node.alt, '');
      expect(node.width, isNull);
      expect(node.height, isNull);
      expect(node.fit, isNull);
      expect(node.borderRadius, isNull);
      expect(node.children, isEmpty);
    });

    test('stores media tokens', () {
      const node = ImageNode(
        'assets/logo.png',
        alt: 'Logo',
        width: 64,
        height: 64,
        fit: ImageFit.contain,
        borderRadius: 8,
      );

      expect(node.alt, 'Logo');
      expect(node.width, 64);
      expect(node.height, 64);
      expect(node.fit, ImageFit.contain);
      expect(node.borderRadius, 8);
    });
  });

  group('LinkNode', () {
    test('exposes its single child', () {
      const node = LinkNode('https://unibox.dev', child: TextNode('Unibox'));

      expect(node.url, 'https://unibox.dev');
      expect(node.newTab, isFalse);
      expect(node.onTap, isNull);
      expect(node.children, hasLength(1));
      expect((node.children.single as TextNode).text, 'Unibox');
    });

    test('supports opening in a new tab and tap handlers', () {
      final node = LinkNode(
        'https://unibox.dev',
        newTab: true,
        onTap: () {},
        child: const TextNode('Unibox'),
      );

      expect(node.newTab, isTrue);
      expect(node.onTap, isNotNull);
    });
  });

  group('StackNode', () {
    test('layers its children in paint order', () {
      const stack = StackNode(
        width: 200,
        height: 100,
        children: [TextNode('back'), TextNode('front')],
      );

      expect(stack.width, 200);
      expect(stack.height, 100);
      expect(stack.children, hasLength(2));
      expect((stack.children.last as TextNode).text, 'front');
    });

    test('defaults to an unsized empty stack', () {
      const stack = StackNode();

      expect(stack.children, isEmpty);
      expect(stack.width, isNull);
      expect(stack.height, isNull);
    });
  });

  group('PositionedNode', () {
    test('stores its offsets and child', () {
      const node = PositionedNode(
        top: 4,
        right: 8,
        bottom: 12,
        left: 16,
        child: TextNode('badge'),
      );

      expect(node.top, 4);
      expect(node.right, 8);
      expect(node.bottom, 12);
      expect(node.left, 16);
      expect(node.isUnpositioned, isFalse);
      expect(node.children, hasLength(1));
      expect((node.children.single as TextNode).text, 'badge');
    });

    test('reports when no offset is set', () {
      const node = PositionedNode(child: TextNode('free'));

      expect(node.isUnpositioned, isTrue);
      expect(node.top, isNull);
      expect(node.left, isNull);
    });
  });

  group('TextInputNode', () {
    test('defaults to a single line, non obscured, uncontrolled input', () {
      const node = TextInputNode();

      expect(node.value, isNull);
      expect(node.placeholder, isNull);
      expect(node.obscureText, isFalse);
      expect(node.multiline, isFalse);
      expect(node.maxLines, isNull);
      expect(node.onChanged, isNull);
      expect(node.onSubmitted, isNull);
      expect(node.children, isEmpty);
    });

    test('stores input configuration and handlers', () {
      final changed = <String>[];
      final submitted = <String>[];
      final node = TextInputNode(
        value: 'secret',
        placeholder: 'Password',
        obscureText: true,
        multiline: true,
        maxLines: 4,
        onChanged: changed.add,
        onSubmitted: submitted.add,
      );

      expect(node.value, 'secret');
      expect(node.placeholder, 'Password');
      expect(node.obscureText, isTrue);
      expect(node.multiline, isTrue);
      expect(node.maxLines, 4);

      node.onChanged?.call('a');
      node.onSubmitted?.call('a');

      expect(changed, ['a']);
      expect(submitted, ['a']);
    });
  });

  group('UINode', () {
    test('is the common supertype of every node', () {
      final nodes = <UINode>[
        const Box(),
        const TextNode('text'),
        const ImageNode('image.png'),
        const LinkNode('https://unibox.dev', child: TextNode('link')),
        const StackNode(),
        const PositionedNode(child: TextNode('positioned')),
        const TextInputNode(),
      ];

      expect(nodes, hasLength(7));
      expect(nodes.map((node) => node.runtimeType).toSet(), hasLength(7));
    });

    test('leaf nodes have no children', () {
      expect(const TextNode('text').children, isEmpty);
      expect(const ImageNode('image.png').children, isEmpty);
      expect(const TextInputNode().children, isEmpty);
    });

    test('parents expose their child nodes', () {
      const child = TextNode('child');

      expect(const LinkNode('https://unibox.dev', child: child).children, [
        child,
      ]);
      expect(const PositionedNode(child: child).children, [child]);
      expect(const Box(children: [child]).children, [child]);
      expect(const StackNode(children: [child]).children, [child]);
    });
  });
}
