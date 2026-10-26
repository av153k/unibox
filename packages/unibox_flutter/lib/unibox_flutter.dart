/// Flutter renderer for the Unibox node tree.
///
/// Exposes `renderFlutter(UINode)` together with the `UINode.toWidget()`
/// extension which turn platform agnostic Unibox nodes into Flutter widgets.
///
/// ```dart
/// import 'package:unibox_core/unibox_core.dart';
/// import 'package:unibox_flutter/unibox_flutter.dart';
///
/// const card = Box(direction: Axis.vertical, gap: 8, children: [
///   TextNode('Hello'),
/// ]);
///
/// Widget widget = card.toWidget();
/// ```
library;

export 'src/render.dart';
