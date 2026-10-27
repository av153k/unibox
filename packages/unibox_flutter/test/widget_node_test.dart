import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_flutter/unibox_flutter.dart';

import 'support/appearance.dart';
import 'support/harness.dart';

/// A widget that only exists to prove an embed is rendered as itself.
class _Marker extends StatelessWidget {
  const _Marker(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(label);
}

/// An embed of another target, which no Flutter renderer can draw.
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
    (Widget child) => DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
      child: child,
    ),
    'the web implementation, which this target never looks at',
  ];
}

void main() {
  group('WidgetNode', () {
    testWidgets('renders the widget inside the surrounding box', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.Box(
          direction: core.Axis.vertical,
          gap: 8,
          children: <core.UINode>[
            core.TextNode('before'),
            WidgetNode(_Marker('chart')),
          ],
        ),
      );

      expect(find.text('before'), findsOneWidget);
      expect(find.byType(_Marker), findsOneWidget);
      expect(find.text('chart'), findsOneWidget);
    });

    testWidgets('carries the key of its node', (tester) async {
      await pumpNode(tester, const WidgetNode(_Marker('chart'), key: 'chart'));

      expect(find.byKey(const ValueKey<Object>('chart')), findsOneWidget);
    });

    testWidgets('exposes the widget as its implementation', (tester) async {
      const WidgetNode node = WidgetNode(_Marker('chart'));

      expect(node.implementations.single, isA<_Marker>());
      expect(node.children, isEmpty);
    });

    testWidgets('reports an embed without an implementation of this target', (
      tester,
    ) async {
      expect(
        () => renderFlutter(const _ForeignEmbed()),
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

  group('an embed of the user\'s own', () {
    testWidgets('wraps its child with the implementation this target draws', (
      tester,
    ) async {
      await pumpNode(tester, const _Badge(child: core.TextNode('New')));

      // The node class is unknown here; the builder received the rendered child
      // and wrapped it, which is what an ink ripple or a hover glow needs.
      final Finder badge = find.byType(DecoratedBox);

      expect(badge, findsOneWidget);
      expect(
        find.descendant(of: badge, matching: find.text('New')),
        findsOneWidget,
      );
    });

    testWidgets('reports a builder that has no child to wrap', (tester) async {
      const _OrphanBuilder node = _OrphanBuilder();

      expect(
        () => renderFlutter(node),
        throwsA(
          isA<StateError>().having(
            (StateError error) => error.message,
            'message',
            contains('no child'),
          ),
        ),
      );
    });

    testWidgets('reports two implementations of this target', (tester) async {
      const _Ambiguous node = _Ambiguous();

      expect(
        () => renderFlutter(node),
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
    testWidgets('renders a node that extends a box as that box', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const _TintedBox(children: <core.UINode>[core.TextNode('Hi')]),
      );

      // The node is not one of the eight: the renderer reaches it through the
      // `Box` it extends, which is how a design-system package ships a card
      // without this package ever knowing its name.
      expect(appearanceOf(tester).backgroundColor, core.BoxColors.blue);
      expect(find.text('Hi'), findsOneWidget);
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
  List<Object> get implementations => <Object>[(Widget child) => child];
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
