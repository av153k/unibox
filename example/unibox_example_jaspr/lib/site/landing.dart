import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

/// The front page: what the library is, and the two ways into it.
///
/// The page answers the question a visitor arrives with — "what is this?" — before
/// it shows anything, and then offers the two things the repository can prove: the
/// Material library as values and nodes, and one page drawn by both renderers.
UINode buildLanding() {
  const MaterialPalette palette = MaterialPalette.light;

  return Box(
    width: double.infinity,
    padding: const BoxSpacing.symmetric(horizontal: 32, vertical: 64),
    gap: 40,
    children: <UINode>[
      Box(
        width: 760,
        gap: 16,
        children: <UINode>[
          TextNode(
            'Describe a screen once.',
            style: MaterialTypography.displayMedium,
          ),
          TextNode(
            'Unibox is one immutable tree of nodes — boxes, text, images, links, '
            'stacks, fields, overlays — drawn by two renderers from that single '
            'description: Flutter widgets in an application, and HTML with CSS in a '
            'browser. They agree because one table of expected appearance holds both '
            'renderer suites to the same answer.',
            style: MaterialTypography.bodyLarge,
            color: palette.onSurfaceVariant,
          ),
          TextNode(
            'The tree is pure Dart with no dependencies. Layout, spacing, colours, '
            'typography and the accessibility tree are written once, state lives in '
            'a store the tree owns, and a design system is a package of values and '
            'nodes rather than a renderer — which is what unibox_material is.',
            style: MaterialTypography.bodyLarge,
            color: palette.onSurfaceVariant,
          ),
        ],
      ),
      ImageNode(
        'assets/hero.svg',
        alt:
            'One immutable Dart node tree on the left, a fork into two panels '
            'showing the same card drawn by Flutter and by Jaspr.',
        width: double.infinity,
      ),
      Box(
        direction: Axis.horizontal,
        crossAlign: CrossAlign.stretch,
        gap: 24,
        children: <UINode>[
          _choice(
            title: 'The Material library',
            body:
                'The fifteen type roles, the colour roles and six components, '
                'typeset and painted by the same node tree.',
            href: 'material/',
            palette: palette,
          ),
          _choice(
            title: 'The same tree, drawn twice',
            body:
                'The example page rendered by Jaspr on the left and Flutter on the '
                'right. Resize the window: both answer the same breakpoint.',
            href: 'showcase/',
            palette: palette,
          ),
        ],
      ),
    ],
  );
}

/// One way in: a bordered card that is a link and tints like a control.
///
/// The tint belongs to the [MaterialInkWell] inside the border, not around it,
/// because a state layer paints *above* the surface it belongs to: wrapped the
/// other way round, the card's own background would cover it.
UINode _choice({
  required String title,
  required String body,
  required String href,
  required MaterialPalette palette,
}) {
  return LinkNode(
    href,
    child: Box(
      width: 360,
      borderRadius: 12,
      border: BoxBorder(color: palette.outlineVariant),
      children: <UINode>[
        MaterialInkWell(
          palette: palette,
          borderRadius: 12,
          padding: const BoxSpacing.all(20),
          child: Box(
            gap: 8,
            children: <UINode>[
              TextNode(title, style: MaterialTypography.titleLarge),
              TextNode(
                body,
                style: MaterialTypography.bodyMedium.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
              TextNode(
                href,
                style: MaterialTypography.labelSmall.copyWith(
                  color: palette.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
