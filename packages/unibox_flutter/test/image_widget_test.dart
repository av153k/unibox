import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The [Image] widget rendered by the harness.
Image renderedImage(WidgetTester tester) =>
    tester.widget<Image>(inNode(find.byType(Image)));

void main() {
  group('ImageNode', () {
    testWidgets('loads the src even when the node lists candidates', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.ImageNode(
          'assets/logo.png',
          width: 40,
          height: 40,
          srcSet: <int, String>{200: 'logo-200.png', 400: 'logo-400.png'},
          sizes: '100vw',
          loading: core.ImageLoading.lazy,
          fetchPriority: core.ImageFetchPriority.high,
        ),
      );

      // Flutter has one source per image: the candidates are a web attribute.
      final ImageProvider<Object> provider = renderedImage(tester).image;

      expect(provider, isA<AssetImage>());
      expect((provider as AssetImage).assetName, 'assets/logo.png');
    });

    testWidgets('loads absolute urls from the network', (tester) async {
      await pumpNode(
        tester,
        const core.ImageNode(
          'https://example.com/cat.png',
          width: 40,
          height: 40,
        ),
      );

      final ImageProvider<Object> provider = renderedImage(tester).image;

      expect(provider, isA<NetworkImage>());
      expect((provider as NetworkImage).url, 'https://example.com/cat.png');
    });

    testWidgets('loads relative paths from the asset bundle', (tester) async {
      await pumpNode(
        tester,
        const core.ImageNode('assets/logo.png', width: 40, height: 40),
      );

      final ImageProvider<Object> provider = renderedImage(tester).image;

      expect(provider, isA<AssetImage>());
      expect((provider as AssetImage).assetName, 'assets/logo.png');
    });

    testWidgets('applies the declared size and fit', (tester) async {
      await pumpNode(
        tester,
        const core.ImageNode(
          'assets/logo.png',
          width: 120,
          height: 60,
          fit: core.ImageFit.cover,
        ),
      );

      final Image image = renderedImage(tester);

      expect(image.width, 120);
      expect(image.height, 60);
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('maps every fit', (tester) async {
      const Map<core.ImageFit, BoxFit> fits = <core.ImageFit, BoxFit>{
        core.ImageFit.cover: BoxFit.cover,
        core.ImageFit.contain: BoxFit.contain,
        core.ImageFit.fill: BoxFit.fill,
        core.ImageFit.scaleDown: BoxFit.scaleDown,
      };

      for (final MapEntry<core.ImageFit, BoxFit> entry in fits.entries) {
        await pumpNode(
          tester,
          core.ImageNode(
            'assets/logo.png',
            width: 10,
            height: 10,
            fit: entry.key,
          ),
        );

        expect(renderedImage(tester).fit, entry.value);
      }
    });

    testWidgets('scales the image down when the node does not ask for a fit', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.ImageNode('assets/logo.png', width: 10, height: 10),
      );

      // Left to `Image`, the picture would scale down anyway; passing it means
      // the web renderer can write the same answer into `object-fit` instead of
      // letting a browser stretch the picture.
      expect(renderedImage(tester).fit, BoxFit.scaleDown);
    });

    testWidgets('clips to the border radius', (tester) async {
      await pumpNode(
        tester,
        const core.ImageNode(
          'assets/logo.png',
          width: 40,
          height: 40,
          borderRadius: 8,
        ),
      );

      final Finder clip = inNode(find.byType(ClipRRect));

      expect(clip, findsOneWidget);
      expect(
        tester.widget<ClipRRect>(clip).borderRadius,
        BorderRadius.circular(8),
      );
    });

    testWidgets('adds no clip without a border radius', (tester) async {
      await pumpNode(
        tester,
        const core.ImageNode('assets/logo.png', width: 40, height: 40),
      );

      expect(inNode(find.byType(ClipRRect)), findsNothing);
    });

    testWidgets('exposes the alt text as a semantic label', (tester) async {
      await pumpNode(
        tester,
        const core.ImageNode(
          'assets/logo.png',
          alt: 'A red fox',
          width: 40,
          height: 40,
        ),
      );

      expect(renderedImage(tester).semanticLabel, 'A red fox');
    });

    testWidgets('omits the semantic label of a decorative image', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.ImageNode('assets/logo.png', width: 40, height: 40),
      );

      expect(renderedImage(tester).semanticLabel, isNull);
    });

    testWidgets('keeps its declared size when the image fails to load', (
      tester,
    ) async {
      await pumpNode(
        tester,
        const core.ImageNode('assets/missing.png', width: 40, height: 60),
      );
      await tester.pumpAndSettle();

      expect(takeAllExceptions(tester), isEmpty);
      expect(tester.getSize(find.byKey(nodeKey)), const Size(40, 60));
    });

    testWidgets('renders inside a box next to text', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          direction: core.Axis.horizontal,
          gap: 12,
          children: [
            core.ImageNode('assets/logo.png', width: 24, height: 24),
            core.TextNode('Label'),
          ],
        ),
      );

      expect(inNode(find.byType(Image)), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
      expect(tester.getSize(find.byType(Row)).width, greaterThan(24));
    });
  });
}

/// Drains every exception reported while pumping images.
///
/// Image loading is asynchronous, so failed asset lookups surface after the
/// first frame; the error builder keeps them from failing the test.
List<Object> takeAllExceptions(WidgetTester tester) {
  final List<Object> exceptions = <Object>[];
  Object? exception = tester.takeException();
  while (exception != null) {
    exceptions.add(exception);
    exception = tester.takeException();
  }
  return exceptions;
}
