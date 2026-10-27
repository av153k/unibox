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
///
/// Every node type also exposes the widget it renders to (`UniboxBox` for a
/// `Box`, `UniboxText` for a `TextNode`, ...), which is what a host or a test
/// needs to address a rendered node without depending on its position.
library;

export 'src/box.dart' show UniboxBox;
export 'src/embed_node.dart' show WidgetEmbedBuilder, WidgetNode;
export 'src/image_node.dart' show UniboxImage;
export 'src/link_node.dart' show LinkOpener, UniboxLink, UniboxLinkScope;
export 'src/render.dart';
export 'src/stack_node.dart' show UniboxStack;
export 'src/text_input_node.dart' show UniboxTextInput;
export 'src/text_node.dart' show UniboxText;
export 'src/text_style_scope.dart' show UniboxTextStyleScope;
