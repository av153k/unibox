import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_core/unibox_core.dart';

/// An `<iframe>` as a node.
///
/// A frame is content only the web can draw, which is what [EmbedNode] is for: the
/// model keeps the payload opaque and the Jaspr renderer draws the component it
/// finds. The showcase page uses two of them to put the two renderings side by side.
final class IframeNode extends EmbedNode {
  /// Creates a frame showing [src], named [title] for a screen reader.
  const IframeNode({required this.src, required this.title, super.key});

  /// The page the frame shows, relative to the document that holds it.
  final String src;

  /// The accessible name of the frame.
  final String title;

  @override
  List<Object> get implementations => <Object>[
    iframe(
      const <Component>[],
      src: src,
      attributes: <String, String>{'title': title},
      styles: const Styles(
        raw: <String, String>{
          'border': '0',
          'width': '100%',
          'height': '100%',
          'display': 'block',
        },
      ),
    ),
  ];
}
