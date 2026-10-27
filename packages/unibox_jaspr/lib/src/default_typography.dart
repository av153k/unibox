import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'values.dart';

/// Declares the typography of the model as the base style of the document.
///
/// A widget tree can wrap its root in a `DefaultTextStyle`; CSS has no such hook,
/// so the answer goes into a `:root` rule, the one selector that reaches every
/// element without a box of its own. Without it a text that declares nothing
/// would be typeset by the browser — 16 pixels of `canvastext`, a colour that
/// flips in a dark theme, at a `normal` line height — while the Flutter renderer
/// would be using the numbers of [core.BoxTextStyle.defaults].
///
/// [core.BoxTextStyle.defaults]: https://pub.dev/documentation/unibox_core/latest/unibox_core/BoxTextStyle-class.html
///
/// It is a rule about the document rather than about an element, so a host that
/// renders other content next to the tree can restyle what it owns, and a host
/// that wants a font family states one: the model leaves the family to the
/// application, because a font file is an asset.
class JasprDefaultTypography extends StatelessComponent {
  /// Creates the rule.
  const JasprDefaultTypography({super.key});

  @override
  Component build(BuildContext context) {
    return Style(
      styles: <StyleRule>[
        StyleRule(
          selector: const Selector(':root'),
          styles: defaultTypographyStyles(),
        ),
      ],
    );
  }
}
