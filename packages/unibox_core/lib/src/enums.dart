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

/// A state a box can be styled for.
///
/// Only states that a pointer, a keyboard and a touch screen all have are part
/// of the model, so every target can express them: `:hover`, `:focus-visible`
/// and `:active` on the web, the same three on Flutter, plus a disabled control
/// on both.
enum BoxState {
  /// The pointer is over the box.
  hover,

  /// The box has keyboard focus.
  focus,

  /// The box is being activated, by a pointer held down or a key held down.
  pressed,

  /// The box does not react to input, see `Box.enabled`.
  disabled,
}

/// The kind of value a single line text input expects.
///
/// The type drives the on-screen keyboard of a touch device and the validation
/// hints of a browser, so typing an address on a phone offers the right keys
/// without any host code.
enum InputType {
  /// Free form text, the default.
  text,

  /// An email address.
  email,

  /// A number.
  number,

  /// A telephone number.
  phone,

  /// A url.
  url,
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

  /// Fit the image inside its bounds without ever enlarging it.
  ///
  /// This is the default, and it is the default for the same reason the typography
  /// has one: the two targets would otherwise answer differently. A Flutter
  /// `Image` without a fit scales the picture down on its own, while a browser
  /// stretches it over its box (`object-fit: fill`), so an undeclared image would
  /// look cropped on one target and squashed on the other. CSS spells this value
  /// `object-fit: scale-down`, which is exactly what `BoxFit.scaleDown` does.
  scaleDown,
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
