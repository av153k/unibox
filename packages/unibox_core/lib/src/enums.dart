/// The direction in which the children of a box are laid out.
enum Axis {
  /// Children are laid out from left to right.
  horizontal,

  /// Children are laid out from top to bottom.
  vertical,
}

/// Distribution of children along the main axis of a box.
enum MainAlign {
  /// Pack children at the start of the main axis.
  start,

  /// Pack children at the center of the main axis.
  center,

  /// Pack children at the end of the main axis.
  end,

  /// Evenly distribute children, with no space at the edges.
  spaceBetween,

  /// Evenly distribute children, with half sized space at the edges.
  spaceAround,

  /// Evenly distribute children, with equal space between and around them.
  spaceEvenly,
}

/// Alignment of children along the cross axis of a box.
enum CrossAlign {
  /// Align children at the start of the cross axis.
  start,

  /// Align children at the center of the cross axis.
  center,

  /// Align children at the end of the cross axis.
  end,

  /// Stretch children to fill the cross axis.
  stretch,
}

/// How content that exceeds the bounds of a box is treated.
enum Overflow {
  /// Content may paint outside of the box.
  visible,

  /// Content is clipped at the box bounds.
  hidden,

  /// The box becomes scrollable along its main axis.
  scroll,
}

/// How an image fills its bounds.
enum ImageFit {
  /// Scale the image to cover its bounds, cropping when needed.
  cover,

  /// Scale the image to fit inside its bounds, preserving aspect ratio.
  contain,

  /// Stretch the image to fill its bounds, ignoring aspect ratio.
  fill,
}

/// Relative weight of a font.
enum FontWeight {
  /// Regular text weight.
  normal,

  /// Slightly emphasized text weight.
  medium,

  /// Strongly emphasized text weight.
  semiBold,

  /// Heaviest supported text weight.
  bold,
}

/// Horizontal alignment of text inside its bounds.
enum TextAlign {
  /// Align text to the left edge (start for left-to-right text).
  left,

  /// Center text horizontally.
  center,

  /// Align text to the right edge.
  right,

  /// Stretch lines so both edges are aligned.
  justify,
}

/// How text that does not fit its bounds is truncated.
enum TextOverflow {
  /// Clip the overflowing text.
  clip,

  /// Truncate the overflowing text with an ellipsis.
  ellipsis,
}
