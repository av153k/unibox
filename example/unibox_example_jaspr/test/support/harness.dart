import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

/// Every DOM element rendered for [finder], in document order.
List<TestRenderElement> elementsOf(Finder finder) => <TestRenderElement>[
  for (final Element match in finder.evaluate()) _domElementOf(match),
];

/// The single DOM element rendered for [finder].
TestRenderElement elementOf(Finder finder) => elementsOf(finder).single;

/// The CSS an element ends up with once inheritance is resolved.
///
/// Only the properties CSS inherits are collected, and the closest declaration
/// wins, which is exactly what a browser does for typography. A box that is
/// styled through a scoped class rule is skipped, since its declarations live in
/// a `<style>` block rather than on the element. A value of `inherit` is skipped
/// as well: it is not a value but the instruction to keep looking up the tree,
/// which is what a renderer writes when it cancels a user agent default.
Map<String, String> inheritedStylesOf(Finder finder) {
  const Set<String> inherited = <String>{
    'font-size',
    'font-weight',
    'font-family',
    'font-style',
    'line-height',
    'letter-spacing',
    'color',
  };

  final Map<String, String> resolved = <String, String>{};
  TestRenderObject? current = elementOf(finder);

  while (current != null) {
    final Map<String, String>? styles = current is TestRenderElement
        ? current.styles
        : null;

    if (styles != null) {
      for (final MapEntry<String, String> style in styles.entries) {
        if (inherited.contains(style.key) && style.value != 'inherit') {
          resolved.putIfAbsent(style.key, () => style.value);
        }
      }
    }

    current = current.parent;
  }

  return resolved;
}

/// The DOM element of a component tree, if any.
TestRenderElement _domElementOf(Element element) {
  DomElement? domElement;

  void visit(Element current) {
    if (domElement != null) {
      return;
    }
    if (current is DomElement) {
      domElement = current;
      return;
    }
    current.visitChildren(visit);
  }

  visit(element);
  return domElement!.renderObject as TestRenderElement;
}

/// The inline styles of the element matched by [finder].
Map<String, String> stylesOf(Finder finder) {
  return elementOf(finder).styles ?? const <String, String>{};
}

/// The HTML attributes of the element matched by [finder].
Map<String, String> attributesOf(Finder finder) {
  return elementOf(finder).attributes ?? const <String, String>{};
}

/// The registered events of the element matched by [finder].
Set<String> eventsOf(Finder finder) =>
    elementOf(finder).events?.keys.toSet() ?? const <String>{};
