import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

void main() {
  group('TextInputNode', () {
    testComponents('renders a text input that fills its container', (
      tester,
    ) async {
      pumpNode(tester, const core.TextInputNode());

      expect(find.tag('input'), findsOneComponent);
      expect(attributesOf(find.tag('input'))['type'], 'text');
      expect(stylesOf(find.tag('input')), <String, String>{
        'box-sizing': 'border-box',
        'width': '100%',
      });
    });

    testComponents('writes the value of a controlled input', (tester) async {
      pumpNode(tester, const core.TextInputNode(value: 'ced'));

      expect(attributesOf(find.tag('input'))['value'], 'ced');
    });

    testComponents('omits the value of an uncontrolled input', (tester) async {
      pumpNode(tester, const core.TextInputNode(placeholder: 'Your name'));

      final Map<String, String> attributes = attributesOf(find.tag('input'));

      expect(attributes.containsKey('value'), isFalse);
      expect(attributes['placeholder'], 'Your name');
    });

    testComponents('renders an obscured input as a password field', (
      tester,
    ) async {
      pumpNode(tester, const core.TextInputNode(obscureText: true));

      expect(attributesOf(find.tag('input'))['type'], 'password');
    });

    testComponents('renders a multiline input as a text area', (tester) async {
      pumpNode(
        tester,
        const core.TextInputNode(
          value: 'First line',
          placeholder: 'Write something',
          multiline: true,
          maxLines: 4,
        ),
      );

      expect(find.tag('input'), findsNothing);
      expect(find.tag('textarea'), findsOneComponent);
      expect(attributesOf(find.tag('textarea')), <String, String>{
        'placeholder': 'Write something',
        'rows': '4',
      });
      expect(find.text('First line'), findsOneComponent);
    });

    testComponents('leaves the rows of a text area unset without maxLines', (
      tester,
    ) async {
      pumpNode(tester, const core.TextInputNode(multiline: true));

      expect(attributesOf(find.tag('textarea')).containsKey('rows'), isFalse);
    });

    testComponents('registers no listeners without callbacks', (tester) async {
      pumpNode(tester, const core.TextInputNode());

      expect(elementOf(find.tag('input')).events ?? const {}, isEmpty);
    });

    testComponents('reports changes through the input event', (tester) async {
      final List<String> changes = <String>[];

      pumpNode(tester, core.TextInputNode(onChanged: changes.add));

      expect(elementOf(find.tag('input')).events?.keys, <String>['input']);
    });

    testComponents('submits on key presses', (tester) async {
      pumpNode(
        tester,
        core.TextInputNode(
          onChanged: (String text) {},
          onSubmitted: (String text) {},
        ),
      );

      expect(elementOf(find.tag('input')).events?.keys, <String>[
        'input',
        'keydown',
      ]);
    });
  });
}
