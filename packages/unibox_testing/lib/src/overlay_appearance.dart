import 'package:unibox_core/unibox_core.dart' as core;

import 'token_difference.dart';

export 'token_difference.dart';

/// How an overlay is presented once it has been rendered.
///
/// The two renderers produce different output — a widget tree on one side, HTML
/// and CSS on the other — so the only thing that can be compared is what the
/// output *does* with an overlay: the colour of the barrier behind it and where
/// on the screen the content sits.
///
/// A renderer suite reads those facts back from its own output and compares them
/// with the ones an `OverlayCase` expects. What the overlay is made of — a scrim,
/// a fixed layer, a route barrier — is each target's business and stays out.
final class OverlayAppearance {
  /// Creates a description of the presentation of a rendered overlay.
  ///
  /// The defaults are the model's: the Material barrier colour and a content
  /// centred on the screen.
  const OverlayAppearance({
    this.barrierColor = core.OverlayNode.defaultBarrierColor,
    this.alignment = core.OverlayAlignment.center,
  });

  /// The colour of the barrier between the page and the content.
  final core.BoxColor barrierColor;

  /// Where the content sits on the screen.
  final core.OverlayAlignment alignment;

  /// The tokens that differ from [expected], keyed by name.
  Map<String, TokenDifference> differencesFrom(OverlayAppearance expected) {
    final Map<String, TokenDifference> differences =
        <String, TokenDifference>{};

    void compare(String token, Object? actualValue, Object? expectedValue) {
      if (actualValue != expectedValue) {
        differences[token] = (actual: actualValue, expected: expectedValue);
      }
    }

    compare('barrierColor', barrierColor, expected.barrierColor);
    compare('alignment', alignment, expected.alignment);

    return differences;
  }

  @override
  bool operator ==(Object other) =>
      other is OverlayAppearance && differencesFrom(other).isEmpty;

  @override
  int get hashCode => Object.hash(barrierColor, alignment);

  @override
  String toString() =>
      'OverlayAppearance(barrierColor: $barrierColor, alignment: $alignment)';
}
