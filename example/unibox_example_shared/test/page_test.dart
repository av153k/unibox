import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

import 'support/tree.dart';

/// The box of the navigation item labelled [label].
Box navItem(UINode page, String label) => flatten(page)
    .whereType<Box>()
    .firstWhere(
      (Box box) =>
          box.semantics?.role == BoxRole.link && textsIn(box).contains(label),
    );

void main() {
  group('ExamplePage', () {
    test('names the pages of the example', () {
      expect(ExamplePage.values, hasLength(2));
      expect(ExamplePage.signup.label, 'Sign up');
      expect(ExamplePage.apartments.label, 'Apartments');
    });
  });

  group('buildExamplePage', () {
    test('fills the host surface', () {
      final Box page = RecordingHost().frame();

      expect(page.width, double.infinity);
      expect(page.height, double.infinity);
      expect(page.backgroundColor, ExamplePalette.canvas);
      expect(page.direction, Axis.vertical);
    });

    test('stacks the navigation above the page it was given', () {
      final Box content = Box(key: 'content');
      final List<UINode> children = RecordingHost()
          .frame(page: content)
          .children;

      expect(children, hasLength(2));
      expect(children.first, isA<Box>());
      expect(children.last, same(content));
    });

    test('offers one item per page', () {
      final Box page = RecordingHost().frame();

      expect(navItem(page, 'Sign up'), isA<Box>());
      expect(navItem(page, 'Apartments'), isA<Box>());
    });

    test('reports the page an item asks for', () {
      final RecordingHost host = RecordingHost();
      final Box page = host.frame();

      navItem(page, 'Apartments').onTap!();
      navItem(page, 'Sign up').onTap!();

      expect(host.navigations, <ExamplePage>[
        ExamplePage.apartments,
        ExamplePage.signup,
      ]);
    });

    test('marks the open page and not the others', () {
      final Box page = RecordingHost().frame(current: ExamplePage.apartments);

      final Box open = navItem(page, 'Apartments');
      final Box other = navItem(page, 'Sign up');

      expect(open.backgroundColor, ExamplePalette.accentSurface);
      expect(open.textStyle?.color, ExamplePalette.accent);
      expect(other.backgroundColor, isNull);
      expect(other.textStyle?.color, ExamplePalette.muted);
    });

    test('keeps the page that is open reachable from the keyboard', () {
      // A navigation item is a link, which is what puts it in the tab order:
      // without a role a box is a plain container.
      final Box item = navItem(RecordingHost().frame(), 'Apartments');

      expect(item.semantics?.role, BoxRole.link);
      expect(item.isFocusable, isTrue);
      expect(item.stateStyle(BoxState.hover), isNotNull);
    });
  });

  group('ExampleLayout', () {
    test('puts the map beside the list from nine hundred pixels on', () {
      // Both hosts read this one number: Flutter compares the width of its
      // surface with it, the web host turns it into a `min-width` query.
      expect(ExampleLayout.wideBreakpoint, 900);
    });
  });
}
