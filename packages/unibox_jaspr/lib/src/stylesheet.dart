import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The classes one rendering needs: one per distinct set of declarations.
///
/// A tree repeats itself — six listings with the same look, a label that appears
/// twice — and writing the same declarations on every element costs more than
/// bytes: an inline `style` beats every rule a host could write, so a page that
/// carried one per element could not be themed with a CSS custom property, a
/// `@media (prefers-color-scheme: dark)` block, or a stylesheet of its own.
///
/// So the renderer collects declarations here instead: the first element that
/// asks for a set registers a class for it, every element with the same set gets
/// the same class name back, and [rules] holds each rule once. Output then grows
/// with the number of *distinct* looks on a page rather than with the number of
/// elements.
///
/// The sheet belongs to one call of `renderJaspr` and travels down the tree in a
/// `UniboxStylesheetScope`, so two pages rendered in one process cannot share a
/// class by accident.
final class UniboxStylesheet {
  /// Creates an empty sheet.
  UniboxStylesheet();

  /// The class name of every declarations key seen so far.
  final Map<String, String> _classNames = <String, String>{};

  /// The rules, in the order their classes were first asked for.
  final List<StyleRule> _rules = <StyleRule>[];

  /// The class for [declarations], built by [rules] the first time it is asked
  /// for.
  ///
  /// [kind] only names the class (`unibox-box-…`, `unibox-text-…`) so the output
  /// says what an element is; the deduplication is [declarations]'s.
  String classFor(
    String kind,
    String declarations,
    List<StyleRule> Function(String className) rules,
  ) {
    final String key = '$kind|$declarations';
    final String? existing = _classNames[key];

    if (existing != null) {
      return existing;
    }

    final String className = 'unibox-$kind-${fnv1a(key)}';
    _classNames[key] = className;
    _rules.addAll(rules(className));

    return className;
  }

  /// Every rule this rendering needs, each one once.
  List<StyleRule> get rules => List<StyleRule>.unmodifiable(_rules);

  /// How many distinct looks the rendering has, which is its CSS cost.
  int get classCount => _classNames.length;
}

/// The declarations of [styles] as text, sorted so the same look always keys the
/// same class.
String declarationsOf(Styles styles) {
  final List<MapEntry<String, String>> entries =
      styles.properties.entries.toList(growable: false)..sort(
        (MapEntry<String, String> a, MapEntry<String, String> b) =>
            a.key.compareTo(b.key),
      );

  return entries
      .map((MapEntry<String, String> entry) => '${entry.key}:${entry.value}')
      .join(';');
}

/// A stable eight character hash of [value] (FNV-1a).
///
/// Tiny, deterministic and dependency free, so a class name is the same on the
/// server and on the client without any coordination.
String fnv1a(String value) {
  var hash = 0x811C9DC5;

  for (final int codeUnit in value.codeUnits) {
    hash = ((hash ^ codeUnit) * 0x01000193) & 0xFFFFFFFF;
  }

  return hash.toRadixString(16).padLeft(8, '0');
}

/// Writes [UniboxStylesheet.rules] as the single `<style>` of a rendering.
///
/// It is placed after the tree so it can be built once every component has
/// registered its class; CSS applies to the whole document wherever the element
/// sits.
class JasprStylesheet extends StatelessComponent {
  /// Creates the stylesheet element of [sheet].
  const JasprStylesheet({required this.sheet, super.key});

  /// The sheet to write out.
  final UniboxStylesheet sheet;

  @override
  Component build(BuildContext context) => Style(styles: sheet.rules);
}

/// Wraps [child] in a sheet of its own when the rendering has none in scope.
///
/// `renderJaspr` opens a sheet around the tree it renders, but a host may begin
/// somewhere else — `JasprStateful` is a component a page can use directly, and it
/// draws the node itself. Whichever component starts a tree calls this, so the
/// looks are written once and no element carries an inline style either way.
Component withStylesheet(BuildContext context, Component child) {
  if (UniboxStylesheetScope.of(context) != null) {
    return child;
  }

  final UniboxStylesheet sheet = UniboxStylesheet();

  return Component.fragment(<Component>[
    UniboxStylesheetScope(sheet: sheet, child: child),
    JasprStylesheet(sheet: sheet),
  ]);
}

/// Hands the sheet of the rendering in progress to every component below it.
///
/// A component built on its own — `JasprBox(box: box)` in a test, or a host
/// rendering one node — finds no scope and writes its declarations inline, which
/// is what it did before the sheet existed.
class UniboxStylesheetScope extends InheritedComponent {
  /// Creates the scope around [child].
  const UniboxStylesheetScope({
    required this.sheet,
    required super.child,
    super.key,
  });

  /// The sheet to register classes in.
  final UniboxStylesheet sheet;

  /// The sheet in scope, or `null` when there is none.
  static UniboxStylesheet? of(BuildContext context) => context
      .dependOnInheritedComponentOfExactType<UniboxStylesheetScope>()
      ?.sheet;

  @override
  bool updateShouldNotify(UniboxStylesheetScope oldComponent) =>
      oldComponent.sheet != sheet;
}
