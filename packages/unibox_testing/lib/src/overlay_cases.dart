import 'package:unibox_core/unibox_core.dart' as core;

import 'overlay_appearance.dart';

/// One overlay together with the presentation every renderer has to give it.
final class OverlayCase {
  /// Creates a case named [description] that renders [node] into [expected].
  const OverlayCase({
    required this.description,
    required this.node,
    required this.expected,
  });

  /// What the case describes, phrased as the test that checks it.
  final String description;

  /// The overlay to render.
  final core.OverlayNode node;

  /// The presentation the rendered output has to have.
  final OverlayAppearance expected;

  @override
  String toString() => 'OverlayCase($description)';
}

/// The overlays every renderer is checked against.
///
/// One case for each token an overlay can carry, and one with all of them, so a
/// renderer has to honour a token on its own and keep honouring it next to the
/// others. Dismissibility is not in the table: it is behaviour, not appearance.
const List<OverlayCase> overlayCases = <OverlayCase>[
  OverlayCase(
    description: 'centres an overlay on the Material barrier',
    node: core.OverlayNode(onDismiss: _dismiss, child: _content),
    expected: OverlayAppearance(),
  ),
  OverlayCase(
    description: 'puts the content against the top edge',
    node: core.OverlayNode(
      onDismiss: _dismiss,
      alignment: core.OverlayAlignment.top,
      child: _content,
    ),
    expected: OverlayAppearance(alignment: core.OverlayAlignment.top),
  ),
  OverlayCase(
    description: 'puts the content against the bottom edge',
    node: core.OverlayNode(
      onDismiss: _dismiss,
      alignment: core.OverlayAlignment.bottom,
      child: _content,
    ),
    expected: OverlayAppearance(alignment: core.OverlayAlignment.bottom),
  ),
  OverlayCase(
    description: 'paints a barrier of another colour, at the bottom',
    node: core.OverlayNode(
      onDismiss: _dismiss,
      alignment: core.OverlayAlignment.bottom,
      barrierColor: _veil,
      child: _content,
    ),
    expected: OverlayAppearance(
      alignment: core.OverlayAlignment.bottom,
      barrierColor: _veil,
    ),
  ),
];

/// The content of every case, so a test can find it in either output.
const core.UINode _content = core.TextNode('Overlay');

/// A half transparent ink, for a barrier of a different colour.
const core.BoxColor _veil = core.BoxColor(0x80112233);

void _dismiss() {}
