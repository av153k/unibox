import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;
import 'package:unibox_jaspr/unibox_jaspr.dart';

/// Renders [node] as the root component of the current test tree.
void pumpNode(ComponentTester tester, core.UINode node) {
  tester.pumpComponent(renderJaspr(node));
}

/// Resolves the DOM element rendered for the component matched by [finder].
///
/// [finder] must match exactly one component; narrow ambiguous finders with
/// `find.tag('div').first` or similar.
TestRenderElement elementOf(Finder finder) {
  final Element match = finder.evaluate().single;
  DomElement? domElement;

  void visit(Element element) {
    if (domElement != null) {
      return;
    }
    if (element is DomElement) {
      domElement = element;
      return;
    }
    element.visitChildren(visit);
  }

  visit(match);
  return domElement!.renderObject as TestRenderElement;
}

/// The inline styles of the element matched by [finder].
Map<String, String> stylesOf(Finder finder) {
  return elementOf(finder).styles ?? const <String, String>{};
}

/// The `class` attribute of the element matched by [finder].
String? classesOf(Finder finder) => elementOf(finder).classes;

/// The raw CSS rendered by the `<style>` element matched by [finder].
String cssOf(Finder finder) {
  return elementOf(finder).children
      .whereType<TestRenderText>()
      .map((TestRenderText child) => child.text)
      .join();
}
