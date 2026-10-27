/// The presentation contract of the two Unibox renderers.
///
/// One table of boxes and the presentation each of them has to be given, checked
/// from the output of every renderer: `unibox_flutter` reads it out of the
/// widget tree it built, `unibox_jaspr` out of the CSS it emitted. Neither reads
/// the node tree, so a renderer that stops honouring a token fails a test
/// instead of drifting away from the other one.
///
/// This package holds the contract, not the tests. A renderer suite imports it,
/// extracts a [BoxAppearance] from its own output and compares it with the
/// [BoxAppearance] of the [BoxCase] the box belongs to.
library;

export 'src/appearance.dart';
export 'src/cases.dart';
