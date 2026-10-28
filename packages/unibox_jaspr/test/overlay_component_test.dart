import 'package:jaspr_test/jaspr_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

void _dismiss() {}

core.OverlayNode overlay({
  core.OverlayAlignment alignment = core.OverlayAlignment.center,
}) => core.OverlayNode(
  alignment: alignment,
  onDismiss: _dismiss,
  child: const core.TextNode('Details'),
);

void main() {
  testComponents('draws a fixed dialog layer above the page', (tester) async {
    pumpNode(tester, overlay());

    final Finder layer = find.tag('div').first;
    expect(stylesOf(layer)['position'], 'fixed');
    expect(attributesOf(layer)['role'], 'dialog');
    expect(attributesOf(layer)['aria-modal'], 'true');
    expect(find.text('Details'), findsOneComponent);
  });

  testComponents('paints the barrier of the node', (tester) async {
    pumpNode(tester, overlay());

    final Map<String, String> barrier = stylesOf(find.tag('div').at(1));

    expect(barrier['position'], 'absolute');
    expect(barrier['inset'], '0');
    expect(barrier['background-color'], 'rgba(0, 0, 0, 0.322)');
  });

  testComponents('paints the content above the barrier', (tester) async {
    pumpNode(tester, overlay());

    // The barrier is positioned, and a positioned box paints above an in-flow one
    // whatever the document order — so the content is positioned too, which puts
    // the later sibling on top. Left static, a dialog was dimmed by its own scrim.
    final Map<String, String> content = stylesOf(find.tag('div').at(2));

    expect(content['position'], 'relative');
  });

  testComponents('places the content where the node asks', (tester) async {
    pumpNode(tester, overlay(alignment: core.OverlayAlignment.top));
    expect(stylesOf(find.tag('div').first)['align-items'], 'flex-start');

    pumpNode(tester, overlay(alignment: core.OverlayAlignment.bottom));
    expect(stylesOf(find.tag('div').first)['align-items'], 'flex-end');

    pumpNode(tester, overlay());
    expect(stylesOf(find.tag('div').first)['align-items'], 'center');
  });

  testComponents('dismisses when the barrier is pressed', (tester) async {
    var dismissals = 0;

    pumpNode(
      tester,
      core.OverlayNode(
        onDismiss: () => dismissals++,
        child: const core.TextNode('Details'),
      ),
    );

    tester.dispatchEvent(find.tag('div').at(1), 'click');

    expect(dismissals, 1);
  });

  testComponents('does not listen when the barrier is inert', (tester) async {
    pumpNode(
      tester,
      core.OverlayNode(
        barrierDismissible: false,
        onDismiss: () => fail('an inert barrier called onDismiss'),
        child: const core.TextNode('Details'),
      ),
    );

    expect(
      elementsOf(find.tag('div'))[1].events?.containsKey('click') ?? false,
      isFalse,
    );
  });
}
