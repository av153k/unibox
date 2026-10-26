import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

/// Every DOM element rendered for [finder], in document order.
List<TestRenderElement> elementsOf(Finder finder) => <TestRenderElement>[
  for (final Element match in finder.evaluate()) _domElementOf(match),
];

/// The single DOM element rendered for [finder].
TestRenderElement elementOf(Finder finder) => elementsOf(finder).single;

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
