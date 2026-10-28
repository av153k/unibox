import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_material/unibox_material.dart';

/// The Material library as one node tree: the type scale, the colour roles and the
/// components, drawn by the web renderer like any other page.
///
/// The page is a demonstration and a claim at once. Every value on it is a `const`
/// in `unibox_material` — no colour is typed into this file — and every component is
/// a node the two renderers already draw, so nothing here is a screenshot.
UINode buildMaterialGallery() {
  const MaterialPalette palette = MaterialPalette.light;

  return Box(
    width: double.infinity,
    padding: const BoxSpacing.symmetric(horizontal: 32, vertical: 32),
    gap: 48,
    children: <UINode>[
      Box(
        gap: 8,
        children: <UINode>[
          TextNode('Material 3', style: MaterialTypography.displaySmall),
          Box(
            width: 720,
            children: <UINode>[
              TextNode(
                'The fifteen type roles, the colour roles and the components of '
                'Material 3, written as values and nodes. Both renderers draw them '
                'from the same tree.',
                style: MaterialTypography.bodyLarge,
                color: palette.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
      _section(
        'Type scale',
        'The fifteen roles as const BoxTextStyle values. A box passes one down; a '
            'text names the one it wants.',
        _typeScale(),
      ),
      _section(
        'Colour roles',
        'MaterialPalette.light and .dark: the roles as const BoxColor values, read '
            'when the tree is built rather than looked up at render time.',
        _palette(palette),
      ),
      _section(
        'Components',
        'Built from the nodes the renderers already draw: a card, a tile and a field '
            'are boxes, and a dialog is an overlay.',
        _components(palette),
      ),
      _overlays(palette),
    ],
  );
}

/// A titled block of the gallery.
UINode _section(String title, String description, UINode content) {
  const MaterialPalette palette = MaterialPalette.light;

  return Box(
    width: double.infinity,
    gap: 16,
    children: <UINode>[
      Box(
        gap: 4,
        children: <UINode>[
          TextNode(title, style: MaterialTypography.titleLarge),
          Box(
            width: 720,
            children: <UINode>[
              TextNode(
                description,
                style: MaterialTypography.bodyMedium,
                color: palette.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
      content,
    ],
  );
}

/// One row per type role: the role's name and a line of text typeset with it.
UINode _typeScale() {
  const MaterialPalette palette = MaterialPalette.light;

  return Box(
    gap: 12,
    children: <UINode>[
      for (final MaterialTypeRole role in MaterialTypeRole.values)
        Box(
          direction: Axis.horizontal,
          crossAlign: CrossAlign.start,
          gap: 24,
          children: <UINode>[
            Box(
              width: 180,
              children: <UINode>[
                TextNode(
                  _label(role.name),
                  style: MaterialTypography.labelMedium,
                  color: palette.onSurfaceVariant,
                ),
              ],
            ),
            Box(
              flex: 1,
              children: <UINode>[
                TextNode(
                  'Sphinx of black quartz',
                  style: MaterialTypography.of(role),
                ),
              ],
            ),
          ],
        ),
    ],
  );
}

/// The palette as rows of swatches: the colour, its role and its value.
UINode _palette(MaterialPalette palette) {
  final List<(String, BoxColor)> roles = <(String, BoxColor)>[
    ('primary', palette.primary),
    ('onPrimary', palette.onPrimary),
    ('primaryContainer', palette.primaryContainer),
    ('onPrimaryContainer', palette.onPrimaryContainer),
    ('surface', palette.surface),
    ('onSurface', palette.onSurface),
    ('onSurfaceVariant', palette.onSurfaceVariant),
    ('surfaceContainerLowest', palette.surfaceContainerLowest),
    ('surfaceContainerLow', palette.surfaceContainerLow),
    ('surfaceContainerHighest', palette.surfaceContainerHighest),
    ('outline', palette.outline),
    ('outlineVariant', palette.outlineVariant),
    ('error', palette.error),
    ('onError', palette.onError),
    ('scrim', palette.scrim),
  ];

  return Box(
    gap: 16,
    children: <UINode>[
      for (int start = 0; start < roles.length; start += 5)
        Box(
          direction: Axis.horizontal,
          gap: 16,
          children: <UINode>[
            for (final (String name, BoxColor color)
                in roles.skip(start).take(5))
              _swatch(name, color, palette),
          ],
        ),
    ],
  );
}

/// One palette entry: the colour, its role and its value.
///
/// The swatch fills the cell: a box with a height and no width is a column's child
/// with no cross size, which is a colour nobody can see. That is exactly what
/// happened the first time this page was published.
UINode _swatch(String name, BoxColor color, MaterialPalette palette) {
  return Box(
    width: 150,
    gap: 6,
    children: <UINode>[
      Box(
        width: double.infinity,
        height: 56,
        borderRadius: 8,
        backgroundColor: color,
        border: BoxBorder(color: palette.outlineVariant),
      ),
      TextNode(name, style: MaterialTypography.labelMedium),
      TextNode(
        _hex(color),
        style: MaterialTypography.labelSmall.copyWith(
          color: palette.onSurfaceVariant,
        ),
      ),
    ],
  );
}

/// A Material button: a filled surface whose state layer is an ink well.
///
/// The tint has to sit *inside* the fill, because a state layer paints above the
/// surface it belongs to; wrapped the other way round, the button's own background
/// would hide it. The callback is empty and the tint is inert on a static page —
/// what the page shows is the shape, the role and the palette.
UINode _button(
  String label,
  BoxColor background,
  BoxColor foreground,
  MaterialPalette palette,
) {
  return Box(
    borderRadius: 20,
    backgroundColor: background,
    border: background == palette.surface
        ? BoxBorder(color: palette.outline)
        : null,
    children: <UINode>[
      MaterialInkWell(
        borderRadius: 20,
        padding: const BoxSpacing.symmetric(horizontal: 20, vertical: 10),
        onTap: () {},
        child: TextNode(
          label,
          style: MaterialTypography.labelLarge.copyWith(color: foreground),
        ),
      ),
    ],
  );
}

/// The two overlays, which a page cannot show inline, and where to see them.
UINode _overlays(MaterialPalette palette) {
  return _section(
    'Overlays',
    'A dialog and a bottom sheet are nodes rather than calls, so a page cannot show '
        'one inline without covering itself. The example opens its sign-up form as a '
        'dialog: open it below, or see both renderings in the showcase.',
    Box(
      direction: Axis.horizontal,
      gap: 24,
      children: <UINode>[
        _linkCard('Open the sign-up dialog', '../web/signup/', palette),
        _linkCard('Compare both renderings', '../showcase/', palette),
      ],
    ),
  );
}

/// A card that is a link, which is what a static page can offer instead of a click.
UINode _linkCard(String label, String href, MaterialPalette palette) {
  return LinkNode(
    href,
    child: MaterialCard(
      width: 320,
      gap: 4,
      children: <UINode>[
        TextNode(label, style: MaterialTypography.titleMedium),
        TextNode(
          href,
          style: MaterialTypography.labelSmall.copyWith(
            color: palette.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

/// `surfaceContainerLow` as `Surface container low`, for a label a reader can scan.
String _label(String camelCase) {
  final String spaced = camelCase.replaceAllMapped(
    RegExp('[A-Z]'),
    (Match match) => ' ${match[0]!.toLowerCase()}',
  );
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

/// A colour as `#RRGGBB`, the way a reader checks it against a design tool.
String _hex(BoxColor color) {
  final String digits = color.value.toRadixString(16).padLeft(8, '0');
  return '#${digits.substring(2).toUpperCase()}';
}

/// The components the package ships, each in the state a static page can show.
UINode _components(MaterialPalette palette) {
  return Box(
    gap: 32,
    children: <UINode>[
      Box(
        direction: Axis.horizontal,
        crossAlign: CrossAlign.center,
        gap: 16,
        children: <UINode>[
          _button('Filled', palette.primary, palette.onPrimary, palette),
          _button(
            'Tonal',
            palette.primaryContainer,
            palette.onPrimaryContainer,
            palette,
          ),
          _button('Outlined', palette.surface, palette.primary, palette),
        ],
      ),
      Box(
        width: 720,
        children: <UINode>[
          TextNode(
            'Hover, focus or press a button: the state layer is a tint over the fill '
            '— 8% of onSurface for a hover, 10% for a focus and a press — which is '
            'why it reads clearly on the tonal and outlined buttons and only faintly '
            "on the filled one. That is Material's value, not a weaker one. A ripple "
            'is an effect the model does not have, and a plain click is inert here '
            'until the client runtime arrives.',
            style: MaterialTypography.labelSmall.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
        ],
      ),
      Box(
        direction: Axis.horizontal,
        crossAlign: CrossAlign.start,
        gap: 24,
        children: <UINode>[
          Box(
            width: 320,
            children: <UINode>[
              MaterialTextField(
                label: 'Email',
                placeholder: 'you@example.com',
                inputType: InputType.email,
              ),
            ],
          ),
          Box(
            width: 320,
            children: <UINode>[
              MaterialTextField(
                label: 'Email',
                placeholder: 'you@example.com',
                value: 'ada@',
                invalid: true,
                message: 'Enter a complete address.',
              ),
            ],
          ),
        ],
      ),
      Box(
        direction: Axis.horizontal,
        crossAlign: CrossAlign.start,
        gap: 24,
        children: <UINode>[
          MaterialCard(
            width: 360,
            gap: 8,
            children: <UINode>[
              TextNode('Order summary', style: MaterialTypography.titleLarge),
              TextNode(
                'Two nights, one room. Check-in on Friday.',
                style: MaterialTypography.bodyMedium.copyWith(
                  color: palette.onSurfaceVariant,
                ),
              ),
              _button('Confirm', palette.primary, palette.onPrimary, palette),
            ],
          ),
          Box(
            flex: 1,
            borderRadius: 12,
            border: BoxBorder(color: palette.outlineVariant),
            children: <UINode>[
              MaterialListTile(
                leading: TextNode(
                  'AL',
                  style: MaterialTypography.titleMedium,
                  color: palette.primary,
                ),
                title: const TextNode('Ada Lovelace'),
                subtitle: const TextNode('ada@example.com'),
                trailing: TextNode(
                  '2m',
                  style: MaterialTypography.labelMedium.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ),
              MaterialListTile(
                title: const TextNode('Charles Babbage'),
                subtitle: const TextNode('charles@example.com'),
                trailing: TextNode(
                  '1h',
                  style: MaterialTypography.labelMedium.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
