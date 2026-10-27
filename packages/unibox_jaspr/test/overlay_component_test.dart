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

  testComponents('places the content where the node asks', (tester) async {
    pumpNode(tester, overlay(alignment: core.OverlayAlignment.top));
    expect(stylesOf(find.tag('div').first)['align-items'], 'flex-start');

    pumpNode(tester, overlay(alignment: core.OverlayAlignment.bottom));
    expect(stylesOf(find.tag('div').first)['align-items'], 'flex-end');

    pumpNode(tester, overlay());
    expect(stylesOf(find.tag('div').first)['align-items'], 'center');
  });
}
