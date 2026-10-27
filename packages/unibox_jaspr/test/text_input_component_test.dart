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
        'font': 'inherit',
        'color': 'inherit',
        'border': 'none',
        'padding': '0',
        'background-color': 'transparent',
        'outline': 'none',
      });
    });

    testComponents('renders a text input without the browser form chrome', (
      tester,
    ) async {
      // A browser draws a border, a padding, a background and a focus ring
      // around a field of its own. None of those has a Flutter counterpart: the
      // renderer draws a field without Material chrome, so the box around it is
      // the only thing that decides how a field looks on either target.
      pumpNode(tester, const core.TextInputNode());

      final Map<String, String> styles = stylesOf(find.tag('input'));

      expect(styles['border'], 'none');
      expect(styles['padding'], '0');
      expect(styles['background-color'], 'transparent');
      expect(styles['outline'], 'none');
      expect(styles['font'], 'inherit');
      expect(styles['color'], 'inherit');
    });

    testComponents('draws no focus ring inside the box that wraps the field', (
      tester,
    ) async {
      // The ring a browser draws sits around the field, which is inside the
      // padding and the border of the box around it, so focusing a field would
      // show a second frame inside the one the tree asked for.
      pumpNode(
        tester,
        const core.Box(
          padding: core.BoxSpacing.all(11),
          border: core.BoxBorder(),
          children: <core.UINode>[core.TextInputNode()],
        ),
      );

      final Map<String, String> field = stylesOf(find.tag('input'));
      final Map<String, String> box = stylesOf(find.tag('div'));

      expect(field['outline'], 'none');
      expect(box['border'], isNotNull);
      expect(box['padding'], '11px');
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

    testComponents('maps the input type to the type attribute', (tester) async {
      pumpNode(
        tester,
        const core.TextInputNode(inputType: core.InputType.email),
      );

      expect(attributesOf(find.tag('input'))['type'], 'email');
      expect(attributesOf(find.tag('input'))['autocomplete'], 'email');
    });

    testComponents('maps every input type', (tester) async {
      const Map<core.InputType, String> expected = <core.InputType, String>{
        core.InputType.text: 'text',
        core.InputType.email: 'email',
        core.InputType.number: 'number',
        core.InputType.phone: 'tel',
        core.InputType.url: 'url',
      };

      for (final MapEntry<core.InputType, String> entry in expected.entries) {
        pumpNode(tester, core.TextInputNode(inputType: entry.key));

        expect(
          attributesOf(find.tag('input'))['type'],
          entry.value,
          reason: 'for ${entry.key.name}',
        );
      }
    });

    testComponents('obscures the type when the node says so', (tester) async {
      pumpNode(
        tester,
        const core.TextInputNode(
          inputType: core.InputType.email,
          obscureText: true,
        ),
      );

      expect(attributesOf(find.tag('input'))['type'], 'password');
    });

    testComponents('disables the field', (tester) async {
      pumpNode(
        tester,
        const core.TextInputNode(value: 'locked', enabled: false),
      );

      expect(attributesOf(find.tag('input'))['disabled'], '');
    });

    testComponents('passes read only, autofocus and the label through', (
      tester,
    ) async {
      pumpNode(
        tester,
        const core.TextInputNode(
          readOnly: true,
          autofocus: true,
          semanticsLabel: 'Email address',
        ),
      );

      final Map<String, String> attributes = attributesOf(find.tag('input'));

      expect(attributes.containsKey('readonly'), isTrue);
      expect(attributes.containsKey('autofocus'), isTrue);
      expect(attributes['aria-label'], 'Email address');
    });

    testComponents('passes the flags to a text area too', (tester) async {
      pumpNode(
        tester,
        const core.TextInputNode(
          multiline: true,
          readOnly: true,
          enabled: false,
          semanticsLabel: 'Message',
        ),
      );

      final Map<String, String> attributes = attributesOf(find.tag('textarea'));

      expect(attributes.containsKey('readonly'), isTrue);
      expect(attributes.containsKey('disabled'), isTrue);
      expect(attributes['aria-label'], 'Message');
    });

    testComponents('reports focus changes', (tester) async {
      final List<bool> focuses = <bool>[];

      pumpNode(tester, core.TextInputNode(onFocusChanged: focuses.add));
      tester.dispatchEvent(find.tag('input'), 'focus');
      tester.dispatchEvent(find.tag('input'), 'blur');

      expect(focuses, <bool>[true, false]);
    });
  });
}
