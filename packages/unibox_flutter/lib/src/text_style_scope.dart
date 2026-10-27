import 'package:flutter/widgets.dart';
import 'package:unibox_core/unibox_core.dart' as core;

/// The typography inherited from the closest Unibox box.
///
/// Flutter's `DefaultTextStyle` carries it for text, but a `TextField` ignores
/// the default text style and uses the Material input style instead. This scope
/// is the explicit marker that a box set typography, so the field only adopts
/// the ambient style when a Unibox box actually asked for it.
class FlutterTextStyleScope extends InheritedWidget {
  /// Creates a scope that provides [style] to its descendants.
  const FlutterTextStyleScope({
    required this.style,
    required super.child,
    super.key,
  });

  /// The typography resolved from every enclosing box, closest last.
  final core.BoxTextStyle style;

  /// The typography of the closest enclosing box, or an empty style.
  static core.BoxTextStyle of(BuildContext context) =>
      maybeOf(context) ?? const core.BoxTextStyle();

  /// The typography of the closest enclosing box, or `null` when there is none.
  static core.BoxTextStyle? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FlutterTextStyleScope>()
        ?.style;
  }

  @override
  bool updateShouldNotify(FlutterTextStyleScope oldWidget) =>
      style != oldWidget.style;
}
