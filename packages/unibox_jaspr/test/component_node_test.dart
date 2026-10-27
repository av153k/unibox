import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_jaspr/unibox_jaspr.dart';

import 'support/appearance.dart';
import 'support/harness.dart';

/// A component that only exists to prove an embed is rendered as itself.
class _Marker extends StatelessComponent {
  const _Marker(this.label);

  final String label;

  @override
  Component build(BuildContext context) =>
      span(<Component>[Component.text(label)]);
}

/// An embed of another target, which no web renderer can draw.
final class _ForeignEmbed extends core.EmbedNode {
  const _ForeignEmbed();

  @override
  List<Object> get implementations => const <Object>[42];
}

/// The embed a user writes for themselves, with one implementation per renderer.
///
/// The class is unknown to both the model and this package: all that makes it
/// render is the payload shapes it brings.
final class _Badge extends core.EmbedNode {
  const _Badge({required super.child});

  @override
  List<Object> get implementations => <Object>[
    (Component child) => div(<Component>[child], classes: 'badge'),
    'the Flutter implementation, which this target never looks at',
  ];
}

void main() {
  group('JasprComponentNode', () {
    testComponents('renders the component inside the surrounding box', (
      tester,
    ) async {
      pumpNode(
        tester,
        core.Box(
          direction: core.Axis.vertical,
          gap: 16,
          children: <core.UINode>[
            const core.TextNode('before'),
            const JasprComponentNode(_Marker('chart')),
          ],
        ),
      );

      expect(find.text('before'), findsOneComponent);
      expect(find.byType(_Marker), findsOneComponent);
      expect(find.text('chart'), findsOneComponent);
    });

    testComponents('carries the key of its node', (tester) async {
      pumpNode(
        tester,
        const JasprComponentNode(_Marker('chart'), key: 'chart'),
      );

      expect(find.byKey(const ValueKey<Object>('chart')), findsOneComponent);
    });

    test('exposes the component as its implementation', () {
      const JasprComponentNode node = JasprComponentNode(_Marker('chart'));

      expect(node.implementations.single, isA<_Marker>());
      expect(node.children, isEmpty);
    });

    test('reports an embed without an implementation of this target', () {
      expect(
        () => renderJaspr(const _ForeignEmbed()),
        throwsA(
          isA<UnsupportedError>().having(
            (UnsupportedError error) => error.message,
            'message',
            contains('int'),
          ),
        ),
      );
    });
  });

  group("an embed of the user's own", () {
    testComponents('wraps its child with the implementation this target draws', (
      tester,
    ) async {
      pumpNode(tester, const _Badge(child: core.TextNode('New')));

      // The node class is unknown here; the builder received the rendered child
      // and wrapped it, which is what a ripple or a hover glow needs.
      expect(find.tag('div'), findsOneComponent);
      expect(classesOf(find.tag('div')), 'badge');
      expect(find.text('New'), findsOneComponent);
    });

    test('reports a builder that has no child to wrap', () {
      expect(
        () => renderJaspr(const _OrphanBuilder()),
        throwsA(
          isA<StateError>().having(
            (StateError error) => error.message,
            'message',
            contains('no child'),
          ),
        ),
      );
    });

    test('reports two implementations of this target', () {
      expect(
        () => renderJaspr(const _Ambiguous()),
        throwsA(
          isA<StateError>().having(
            (StateError error) => error.message,
            'message',
            contains('ambiguous'),
          ),
        ),
      );
    });
  });

  group("a box of the user's own", () {
    testComponents('renders a node that extends a box as that box', (
      tester,
    ) async {
      pumpNode(
        tester,
        const _TintedBox(children: <core.UINode>[core.TextNode('Hi')]),
      );

      // The node is not one of the eight: the renderer reaches it through the
      // `Box` it extends, which is how a design-system package ships a card
      // without this package ever knowing its name.
      expect(appearanceOf().backgroundColor, core.BoxColors.blue);
      expect(find.text('Hi'), findsOneComponent);
    });
  });
}

/// A box of an application's own, which is still a box.
final class _TintedBox extends core.Box {
  const _TintedBox({super.children})
    : super(backgroundColor: core.BoxColors.blue);
}

/// A builder with nothing to wrap.
final class _OrphanBuilder extends core.EmbedNode {
  const _OrphanBuilder();

  @override
  List<Object> get implementations => <Object>[(Component child) => child];
}

/// Two implementations this target could draw, which is a mistake.
final class _Ambiguous extends core.EmbedNode {
  const _Ambiguous();

  @override
  List<Object> get implementations => const <Object>[
    _Marker('one'),
    _Marker('two'),
  ];
}
