import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_example_jaspr/app.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

import 'support/harness.dart';

/// The CSS weight of a core weight, as the renderer emits it.
String weightOf(core.FontWeight weight) {
  return switch (weight) {
    core.FontWeight.normal => '400',
    core.FontWeight.medium => '500',
    core.FontWeight.semiBold => '600',
    core.FontWeight.bold => '700',
  };
}

/// The CSS colour of a core colour, as the renderer emits it.
String colorOf(core.BoxColor color) =>
    '#${color.value.toRadixString(16).substring(2)}';

/// A logical pixel value the way CSS writes it.
String pixelsOf(double value) =>
    '${value == value.roundToDouble() ? value.toInt() : value}px';

/// The ARIA role of a core role, as the renderer emits it.
String roleOf(core.BoxRole role) {
  return switch (role) {
    core.BoxRole.none => '',
    core.BoxRole.button => 'button',
    core.BoxRole.checkbox => 'checkbox',
    core.BoxRole.switch_ => 'switch',
    core.BoxRole.link => 'link',
    core.BoxRole.heading => 'heading',
  };
}

/// The element that carries the styles of the text [text] is rendered for.
Finder textElement(String text) =>
    find.ancestor(of: find.text(text), matching: find.tag('span'));

/// The attributes of the box that describes the visible text [label].
///
/// The box with the role is somewhere above the text, so the closest ancestor
/// that carries a role is the one the fixture talks about.
Map<String, String> describedAttributesOf(String label) {
  final Finder ancestors = find.ancestor(
    of: find.text(label),
    matching: find.tag('div'),
  );

  return elementsOf(ancestors)
          .firstWhere(
            (TestRenderElement element) => element.attributes?['role'] != null,
          )
          .attributes ??
      const <String, String>{};
}

void main() {
  group('card parity', () {
    testComponents('renders every text with the shared typography', (
      tester,
    ) async {
      tester.pumpComponent(const UniboxExampleApp());

      for (final TextFact fact in CardParity.texts) {
        final Map<String, String> styles = inheritedStylesOf(
          textElement(fact.text),
        );
        final core.BoxTextStyle expected = fact.typography;
        final core.FontWeight? weight = expected.fontWeight;
        final core.BoxColor? color = expected.color;

        expect(find.text(fact.text), findsOneComponent, reason: fact.text);
        if (expected.fontSize != null) {
          expect(
            styles['font-size'],
            pixelsOf(expected.fontSize!),
            reason: fact.text,
          );
        }
        if (weight != null) {
          expect(styles['font-weight'], weightOf(weight), reason: fact.text);
        }
        if (color != null) {
          expect(styles['color'], colorOf(color), reason: fact.text);
        }
      }
    });

    testComponents('renders the shared number of fields', (tester) async {
      tester.pumpComponent(const UniboxExampleApp());

      expect(find.tag('input'), findsNComponents(CardParity.inputCount));
    });

    testComponents('describes every shared role', (tester) async {
      tester.pumpComponent(const UniboxExampleApp());

      for (final RoleFact fact in CardParity.roles) {
        final Map<String, String> attributes = describedAttributesOf(
          fact.label,
        );

        expect(attributes['role'], roleOf(fact.role), reason: fact.label);
        expect(attributes['aria-label'], fact.label);
        if (fact.checked != null) {
          expect(attributes['aria-checked'], '${fact.checked}');
        }
      }
    });
  });
}
