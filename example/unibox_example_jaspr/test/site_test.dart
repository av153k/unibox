import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_example_jaspr/site/gallery.dart';
import 'package:unibox_example_jaspr/site/showcase.dart';

/// Pins the two page trees the site is made of.
///
/// They are node trees, so `validateTree` is the first check a page has to pass —
/// the site is built with the library it documents, and a page that no renderer can
/// honour would be an embarrassing demonstration.
void main() {
  test('the gallery is a valid tree that shows the Material package', () {
    final UINode gallery = buildMaterialGallery();

    expect(validateTree(gallery), isEmpty);
    expect(_texts(gallery), contains('Material 3'));
    expect(_texts(gallery), contains('Sphinx of black quartz'));
    expect(_texts(gallery), contains('Ada Lovelace'));
  });

  test('the showcase puts the two renderings side by side', () {
    final UINode showcase = buildShowcase();

    expect(validateTree(showcase), isEmpty);
    expect(_embeds(showcase), hasLength(2));
  });
}

/// Every text under [node], which is how a page assertion reads.
Iterable<String> _texts(UINode node) sync* {
  if (node is TextNode) {
    yield node.text;
  }

  for (final UINode child in node.children) {
    yield* _texts(child);
  }
}

/// Every embed under [node]: the frames of the showcase.
Iterable<EmbedNode> _embeds(UINode node) sync* {
  if (node is EmbedNode) {
    yield node;
  }

  for (final UINode child in node.children) {
    yield* _embeds(child);
  }
}
