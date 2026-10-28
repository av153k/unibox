import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The family both hosts ship.
///
/// The Flutter app bundles the same files through `flutter: fonts:` in its
/// pubspec, which is what makes `w400`, `w500`, `w600` and `w700` four *drawn*
/// faces on both renderings. Without them a browser substitutes the nearest face
/// its system family has and Skia does the same, from a different family — so a
/// semibold page and a semibold app came out at visibly different weights.
const String fontFamily = 'UniboxText';

/// The weights the example ships, in the order a browser prefers them.
const List<String> fontWeights = <String>['400', '500', '600', '700'];

/// The `@font-face` rules of the family, one per weight.
///
/// [prefix] is how far the document sits from the site root — `''` for `/`,
/// `'../'` for `/material/`, `'../../'` for `/web/listings/`. The site writes no
/// `<base>` element, so a relative url is resolved against the document, and every
/// document has to say where it is.
String fontFaceCss(String prefix) {
  String face(String weight) =>
      """
@font-face {
  font-family: '$fontFamily';
  font-style: normal;
  font-weight: $weight;
  font-display: swap;
  src: url(${prefix}assets/fonts/roboto-$weight.ttf) format('truetype');
}""";

  return fontWeights.map(face).join();
}

/// The rules as the one `<style>` a document carries in its head.
///
/// `StyleRule.fontFace` states a family and a url but no weight, and the example
/// needs four weights of one family, so the block is written out.
Component fontFaces(String prefix) => _InlineStyle(fontFaceCss(prefix));

/// A `<style>` element holding [css] verbatim.
class _InlineStyle extends StatelessComponent {
  const _InlineStyle(this.css);

  final String css;

  @override
  Component build(BuildContext context) =>
      Component.element(tag: 'style', children: <Component>[RawText(css)]);
}
