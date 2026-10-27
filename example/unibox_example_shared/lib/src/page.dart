import 'package:unibox_core/unibox_core.dart';

import 'theme.dart';

/// The destinations of the navigation bar.
///
/// The names live here rather than in a host, because both hosts navigate the
/// same way: they keep what is open in their own state and pass the destination
/// that was asked for back into [buildExamplePage].
///
/// [signup] is not a page: it is the sign-up form, which the frame shows as a
/// dialog over the listings. [apartments] is the page itself.
enum ExamplePage {
  /// The sign-up form, shown as a dialog over the page.
  signup('Sign up'),

  /// The list of apartments, with the map beside it when there is room.
  apartments('Apartments');

  const ExamplePage(this.label);

  /// The label of the destination in the navigation bar.
  final String label;
}

/// The layout facts both hosts have to agree on.
abstract final class ExampleLayout {
  /// The narrowest surface that shows the listings and the map side by side.
  ///
  /// The number lives here because both hosts are asked the same question and
  /// have to answer it the same way: Flutter compares the width of its surface
  /// with it, the web host turns it into a `min-width` media query. A breakpoint
  /// is not a token — a box cannot know how wide the surface is, so it cannot
  /// decide anything from it — which is why it belongs to the page that needs it
  /// instead of to `unibox_core`.
  static const double wideBreakpoint = 900;
}

/// The frame every page is drawn in: the canvas, the navigation bar, [page] and,
/// when it is open, [dialog].
///
/// [dialog] is an [OverlayNode] — `exampleView` builds it from `buildSignupDialog`
/// while the form is open and leaves it out when it is closed. Presence is
/// therefore the state of the page, exactly like the listings it is drawn over,
/// and the frame only places it.
///
/// The bar is part of the tree, not of a host. It is boxes and text like
/// everything else, and it changes what is open through `onTap`, exactly like the
/// newsletter opt-in toggles the form: the host owns the value, the tree asks for
/// a new one. That is what keeps the navigation identical in Flutter and on
/// the web instead of being a router on one side and a widget on the other.
///
/// [page] is expected to fill the space below the bar, which is what the listings
/// page does with `flex: 1`.
Box buildExamplePage({
  required ExamplePage current,
  required void Function(ExamplePage page) onNavigate,
  required UINode page,
  OverlayNode? dialog,
}) {
  return Box(
    direction: Axis.vertical,
    width: double.infinity,
    height: double.infinity,
    backgroundColor: ExamplePalette.canvas,
    children: <UINode>[
      _navigationBar(current: current, onNavigate: onNavigate),
      page,
      ?dialog,
    ],
  );
}

/// The bar above every page: the name of the example and one item per
/// destination.
///
/// The bar is a row that pushes its two ends apart, and the shadow with no blur
/// is the hairline under it: a `BoxBorder` draws on all four sides, while one
/// offset pixel of a shadow draws the single line a navigation bar needs, with
/// the same two tokens in both renderers.
UINode _navigationBar({
  required ExamplePage current,
  required void Function(ExamplePage page) onNavigate,
}) {
  return Box(
    direction: Axis.horizontal,
    mainAlign: MainAlign.spaceBetween,
    crossAlign: CrossAlign.center,
    width: double.infinity,
    padding: const BoxSpacing.symmetric(horizontal: 24, vertical: 12),
    // The bar is the navigation of the page, so the web renders a `<nav>`.
    semantics: const BoxSemantics(element: BoxElement.nav),
    backgroundColor: ExamplePalette.surface,
    shadow: const BoxShadow(
      color: BoxColor(0x14000000),
      offsetY: 1,
      blurRadius: 0,
    ),
    textStyle: ExampleType.body,
    children: <UINode>[
      const TextNode('Unibox', style: ExampleType.brand),
      Box(
        direction: Axis.horizontal,
        crossAlign: CrossAlign.center,
        gap: 4,
        children: <UINode>[
          for (final ExamplePage page in ExamplePage.values)
            _navigationItem(
              page,
              current: page == current,
              onTap: () => onNavigate(page),
            ),
        ],
      ),
    ],
  );
}

/// One item of the navigation: a label, highlighted while its destination is
/// open.
///
/// An item that changes the page is a [BoxRole.link]; the one that opens the
/// sign-up dialog is a [BoxRole.button], because it does not take the reader
/// anywhere — it asks for a form. Only the page can be the current document, so
/// `aria-current` is left off the dialog's trigger. The label is left out of the
/// semantics on purpose: the visible text already says where the item goes, and a
/// second copy could only drift away from it.
UINode _navigationItem(
  ExamplePage page, {
  required bool current,
  required TapCallback onTap,
}) {
  return Box(
    onTap: onTap,
    direction: Axis.horizontal,
    mainAlign: MainAlign.center,
    padding: const BoxSpacing.symmetric(horizontal: 12, vertical: 6),
    borderRadius: 8,
    backgroundColor: current ? ExamplePalette.accentSurface : null,
    textStyle: current ? ExampleType.navCurrent : ExampleType.nav,
    semantics: BoxSemantics(
      role: page == ExamplePage.signup ? BoxRole.button : BoxRole.link,
      // The item of the page the reader is on: `aria-current` on the web, the
      // selected item of a set in Flutter. A dialog is not a document.
      current: current && page == ExamplePage.apartments
          ? BoxCurrent.page
          : null,
    ),
    stateStyles: const <BoxState, BoxStyle>{
      BoxState.hover: BoxStyle(backgroundColor: ExamplePalette.accentSurface),
    },
    transition: ExampleType.transition,
    children: <UINode>[TextNode(page.label)],
  );
}
