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

    testComponents('registers a click listener on the opt-in and the button', (
      tester,
    ) async {
      tester.pumpComponent(const UniboxExampleApp());

      final List<TestRenderElement> clickable = elementsOf(find.tag('div'))
          .where(
            (TestRenderElement element) =>
                element.events?.containsKey('click') ?? false,
          )
          .toList();

      expect(clickable, hasLength(2));
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
  });
}
