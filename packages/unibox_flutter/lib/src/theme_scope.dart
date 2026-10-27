import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

/// Hands the theme of a rendering to the boxes and texts inside it.
///
/// It is a scope and not a lookup: the theme arrives as an argument to
/// `renderFlutter` and travels down the widget tree, so nothing reads ambient
/// state a host did not give, and every node below resolves against the same
/// value. A widget built outside a rendering finds no scope and resolves against
/// an empty theme, which fails loudly on the first role it meets.
class UniboxThemeScope extends InheritedWidget {
  /// Creates the scope around [child].
  const UniboxThemeScope({
    required this.theme,
    required super.child,
    super.key,
  });

  /// The values the roles of the tree stand for.
  final core.UniboxTheme theme;

  /// The theme in scope, or `null` when there is none.
  static core.UniboxTheme? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UniboxThemeScope>()?.theme;

  @override
  bool updateShouldNotify(UniboxThemeScope oldWidget) =>
      oldWidget.theme != theme;
}
