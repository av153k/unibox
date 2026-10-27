import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:unibox_example_shared/unibox_example_shared.dart';

/// The class the emitted rules target.
///
/// The component is used once per page, so one fixed name is enough; a second
/// instance would simply share the same two rules.
const String _wideOnlyClass = 'unibox-example-wide-only';

/// Shows [child] only when the viewport is at least
/// [ExampleLayout.wideBreakpoint] wide.
///
/// The static export is rendered before a browser exists, so the web host cannot
/// measure the window the way the Flutter host does — and it does not have to:
/// CSS knows the width, and a media query is the browser's own breakpoint test,
/// so the answer arrives when the page is laid out instead of when it is built.
///
/// Below the breakpoint the element is `display: none`, which takes it and
/// everything in it out of the row — the same result as the Flutter host, which
/// passes no panel at all. Above the breakpoint it is `display: contents`: the
/// element generates no box of its own, so the panel inside becomes a child of
/// the row in its place and keeps the `flex` factor that makes it the second
/// column. Anything that keeps a box of its own here would leave an empty column
/// on a narrow viewport or a column without a width on a wide one.
///
/// Both rules live in a `<style>` element and neither is inline: an inline
/// `display` would beat the media query, and the panel would never come back.
class WideOnly extends StatelessComponent {
  /// Creates a gate around [child].
  const WideOnly({required this.child, super.key});

  /// The content to show on a wide viewport.
  final Component child;

  @override
  Component build(BuildContext context) {
    return Component.fragment(<Component>[
      Style(
        styles: <StyleRule>[
          StyleRule(
            selector: const Selector.className(_wideOnlyClass),
            styles: Styles(display: Display.none),
          ),
          StyleRule.media(
            query: MediaQuery.screen(
              minWidth: Unit.pixels(ExampleLayout.wideBreakpoint),
            ),
            styles: <StyleRule>[
              StyleRule(
                selector: const Selector.className(_wideOnlyClass),
                styles: Styles(display: Display.contents),
              ),
            ],
          ),
        ],
      ),
      div(<Component>[child], classes: _wideOnlyClass),
    ]);
  }
}
