import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';
import 'package:unibox_example_jaspr/app.dart';

import 'support/harness.dart';

void main() {
  group('UniboxExampleApp', () {
    testComponents('renders the shared node tree', (tester) async {
      tester.pumpComponent(const UniboxExampleApp());

      expect(find.text('Join Unibox'), findsOneComponent);
      expect(find.text('One description, two renderers.'), findsOneComponent);
      expect(find.tag('input'), findsNComponents(2));
      expect(find.text('Create account'), findsOneComponent);
      expect(find.text('Read the docs'), findsOneComponent);

      final Map<String, String> link = attributesOf(find.tag('a'));

      expect(link['href'], 'https://unibox.dev');
      expect(link['target'], '_blank');
    });

    testComponents('fills the viewport', (tester) async {
      tester.pumpComponent(const UniboxExampleApp());

      final Map<String, String> page = stylesOf(find.tag('div').first);

      expect(page['width'], '100%');
      expect(page['height'], '100%');
    });

    testComponents('wires both fields to the host', (tester) async {
      tester.pumpComponent(const UniboxExampleApp());

      final List<TestRenderElement> fields = elementsOf(find.tag('input'));

      expect(fields, hasLength(2));
      for (final TestRenderElement field in fields) {
        expect(field.events?.keys, contains('input'));
      }
      expect(
        attributesOf(find.tag('input').first)['placeholder'],
        'Ada Lovelace',
      );
      expect(
        attributesOf(find.tag('input').last)['placeholder'],
        'ada@example.com',
      );
    });

    testComponents(
      'registers a click listener on the navigation and the opt-in',
      (tester) async {
        tester.pumpComponent(const UniboxExampleApp());

        final List<TestRenderElement> clickable = elementsOf(find.tag('div'))
            .where(
              (TestRenderElement element) =>
                  element.events?.containsKey('click') ?? false,
            )
            .toList();

        // Two navigation items plus the opt-in row; the button is disabled until
        // the form is complete.
        expect(clickable, hasLength(3));

        final TestRenderElement button = elementsOf(find.tag('div')).firstWhere(
          (TestRenderElement element) =>
              element.attributes?['role'] == 'button',
        );
        expect(button.attributes?['aria-disabled'], 'true');
        expect(button.attributes?.containsKey('tabindex'), isFalse);
      },
    );

    testComponents('enables the button once the form is complete', (
      tester,
    ) async {
      tester.pumpComponent(
        const UniboxExampleApp(
          initialState: SignupFormState(name: 'Ada', email: 'ada@example.com'),
        ),
      );

      final List<TestRenderElement> clickable = elementsOf(find.tag('div'))
          .where(
            (TestRenderElement element) =>
                element.events?.containsKey('click') ?? false,
          )
          .toList();

      expect(clickable, hasLength(4));

      final TestRenderElement button = elementsOf(find.tag('div')).firstWhere(
        (TestRenderElement element) => element.attributes?['role'] == 'button',
      );
      expect(button.attributes?['aria-disabled'], isNull);
      expect(button.attributes?['tabindex'], '0');
      expect(button.events?.keys, contains('keydown'));
    });

    testComponents('checks the opt-in when the newsletter is on', (
      tester,
    ) async {
      tester.pumpComponent(
        const UniboxExampleApp(initialState: SignupFormState(newsletter: true)),
      );

      expect(find.text('✓'), findsOneComponent);
    });

    testComponents('renders the confirmation of a submitted form', (
      tester,
    ) async {
      tester.pumpComponent(
        const UniboxExampleApp(
          initialState: SignupFormState(
            name: 'Ada',
            email: 'ada@example.com',
            submitted: true,
          ),
        ),
      );

      expect(
        find.text('Thanks, Ada! We will write to ada@example.com.'),
        findsOneComponent,
      );
      expect(find.text('Looks good - press Create account.'), findsNothing);
    });

    testComponents('offers a navigation item per page', (tester) async {
      tester.pumpComponent(const UniboxExampleApp());

      expect(find.text('Sign up'), findsOneComponent);
      expect(find.text('Apartments'), findsOneComponent);

      final TestRenderElement item = elementsOf(find.tag('div')).firstWhere(
        (TestRenderElement element) => element.attributes?['role'] == 'link',
      );

      expect(item.attributes?['tabindex'], '0');
      expect(item.events?.keys, contains('click'));
    });
  });

  group('apartments page', () {
    testComponents('renders the listings of the shared page', (tester) async {
      tester.pumpComponent(
        const UniboxExampleApp(initialPage: ExamplePage.apartments),
      );

      // The heading and the navigation item carry the same label.
      expect(find.text('Apartments'), findsNComponents(2));
      expect(find.text('Via Bellavista 12'), findsOneComponent);
      expect(find.text('3 rooms · 84 m²'), findsOneComponent);
      expect(find.text('€1850 / month'), findsOneComponent);
      expect(find.text('Join Unibox'), findsNothing);
    });

    testComponents('scrolls the listings inside the page', (tester) async {
      tester.pumpComponent(
        const UniboxExampleApp(initialPage: ExamplePage.apartments),
      );

      final List<TestRenderElement> scrollable = elementsOf(find.tag('div'))
          .where(
            (TestRenderElement element) =>
                element.styles?['overflow'] == 'auto',
          )
          .toList();

      expect(scrollable, hasLength(1));
      // The scrolling box is the page below the navigation, not the document: it
      // is the part of the frame that takes the room that is left.
      expect(scrollable.single.styles?['flex-grow'], '1');
    });

    testComponents('shows the map from the breakpoint up', (tester) async {
      tester.pumpComponent(
        const UniboxExampleApp(initialPage: ExamplePage.apartments),
      );

      expect(find.text('Map'), findsOneComponent);

      final String css = allCss();

      // Hidden by default, so a narrow viewport lays the list out on its own, and
      // displayed as a transparent wrapper from the breakpoint both hosts share —
      // `contents` keeps no box of its own, so the panel is the second column of
      // the row. Neither rule is inline: an inline `display` would beat the media
      // query.
      expect(css, contains('display: none;'));
      expect(css, contains('display: contents;'));
      expect(css, contains('@media screen and (min-width: 900px)'));
    });

    testComponents('leaves the map out of the card page', (tester) async {
      tester.pumpComponent(const UniboxExampleApp());

      expect(find.text('Map'), findsNothing);
      expect(allCss(), isNot(contains('@media screen and (min-width: 900px)')));
    });
  });
}
