import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

void main() {
  group('BoxColor', () {
    test('exposes the channels of a raw ARGB value', () {
      const color = BoxColor(0x8042A5F0);

      expect(color.alpha, 0x80);
      expect(color.red, 0x42);
      expect(color.green, 0xA5);
      expect(color.blue, 0xF0);
      expect(color.opacity, closeTo(0x80 / 0xFF, 1e-9));
      expect(color.isOpaque, isFalse);
      expect(color.isTransparent, isFalse);
    });

    test('builds opaque colors from rgb channels', () {
      const color = BoxColor.rgb(0x2D, 0x6C, 0xF3);

      expect(color.value, 0xFF2D6CF3);
      expect(color.isOpaque, isTrue);
    });

    test('builds colors from rgba channels', () {
      const color = BoxColor.rgba(255, 128, 0, 128);

      expect(color.value, 0x80FF8000);
      expect(color.alpha, 128);
    });

    test('defaults rgba to an opaque color', () {
      expect(const BoxColor.rgba(1, 2, 3).value, 0xFF010203);
    });

    test('provides presets', () {
      expect(BoxColor.black.value, 0xFF000000);
      expect(BoxColor.white.value, 0xFFFFFFFF);
      expect(BoxColor.transparent.value, 0x00000000);
      expect(BoxColor.transparent.isTransparent, isTrue);
    });

    test('withOpacity scales the alpha channel', () {
      const color = BoxColor.rgb(10, 20, 30);

      expect(color.withOpacity(0.5).alpha, 128);
      expect(color.withOpacity(2).alpha, 255);
      expect(color.withOpacity(-1).alpha, 0);
      expect(color.withOpacity(0.5).red, 10);
      expect(color.withOpacity(0.5).blue, 30);
    });

    test('withAlpha replaces only the alpha channel', () {
      const color = BoxColor.rgba(10, 20, 30, 255);

      expect(color.withAlpha(64), const BoxColor.rgba(10, 20, 30, 64));
    });

    test('implements value equality', () {
      expect(const BoxColor(0xFF112233), const BoxColor(0xFF112233));
      expect(
        const BoxColor(0xFF112233).hashCode,
        const BoxColor(0xFF112233).hashCode,
      );
      expect(const BoxColor(0xFF112233), isNot(const BoxColor(0xFF112234)));
      expect(const BoxColor(0xFF112233).toString(), 'BoxColor(0xFF112233)');
    });
  });

  group('BoxSpacing', () {
    test('all applies the same inset on every edge', () {
      const spacing = BoxSpacing.all(12);

      expect(spacing.top, 12);
      expect(spacing.right, 12);
      expect(spacing.bottom, 12);
      expect(spacing.left, 12);
      expect(spacing.horizontal, 24);
      expect(spacing.vertical, 24);
      expect(spacing.isZero, isFalse);
    });

    test('symmetric distributes horizontal and vertical insets', () {
      const spacing = BoxSpacing.symmetric(horizontal: 8, vertical: 4);

      expect(spacing.top, 4);
      expect(spacing.right, 8);
      expect(spacing.bottom, 4);
      expect(spacing.left, 8);
      expect(spacing.hasUniformVertical, isTrue);
      expect(spacing.hasUniformHorizontal, isTrue);
    });

    test('only names individual edges', () {
      const spacing = BoxSpacing.only(top: 1, left: 3);

      expect(spacing.top, 1);
      expect(spacing.right, 0);
      expect(spacing.bottom, 0);
      expect(spacing.left, 3);
      expect(spacing.hasUniformHorizontal, isFalse);
    });

    test('zero has no insets', () {
      expect(BoxSpacing.zero.isZero, isTrue);
      expect(BoxSpacing.zero, const BoxSpacing());
    });

    test('copyWith replaces single edges', () {
      const spacing = BoxSpacing.all(4);

      expect(spacing.copyWith(top: 9).top, 9);
      expect(spacing.copyWith(top: 9).left, 4);
      expect(
        spacing.copyWith(left: 2),
        const BoxSpacing(top: 4, right: 4, bottom: 4, left: 2),
      );
    });

    test('implements value equality', () {
      expect(const BoxSpacing.all(6), const BoxSpacing.all(6));
      expect(
        const BoxSpacing.all(6).hashCode,
        const BoxSpacing.all(6).hashCode,
      );
      expect(const BoxSpacing.all(6), isNot(const BoxSpacing.all(7)));
    });
  });

  group('BoxBorder and BoxShadow', () {
    test('border defaults to a visible black hairline', () {
      const border = BoxBorder();

      expect(border.width, 1);
      expect(border.color, BoxColor.black);
      expect(border.isVisible, isTrue);
      expect(const BoxBorder.none().isVisible, isFalse);
    });

    test('border implements value equality', () {
      expect(
        const BoxBorder(width: 2, color: BoxColor.white),
        const BoxBorder(width: 2, color: BoxColor.white),
      );
      expect(const BoxBorder(width: 2), isNot(const BoxBorder(width: 3)));
    });

    test('shadow implements value equality', () {
      const shadow = BoxShadow(color: BoxColor.black, blurRadius: 8);

      expect(shadow.blurRadius, 8);
      expect(shadow, const BoxShadow(blurRadius: 8));
      expect(shadow, isNot(const BoxShadow(blurRadius: 9)));
    });
  });

  group('BoxStyle', () {
    test('starts empty', () {
      expect(const BoxStyle().isEmpty, isTrue);
      expect(const BoxStyle(gap: 8).isEmpty, isFalse);
    });

    test('merge lets the overlay win', () {
      const base = BoxStyle(
        padding: BoxSpacing.all(16),
        backgroundColor: BoxColor.white,
        gap: 4,
      );
      const overlay = BoxStyle(gap: 12, width: 200);

      final merged = base.merge(overlay);

      expect(merged.padding, BoxSpacing.all(16));
      expect(merged.backgroundColor, BoxColor.white);
      expect(merged.gap, 12);
      expect(merged.width, 200);
    });

    test('merge keeps the base when the overlay is null', () {
      const base = BoxStyle(gap: 4);

      expect(base.merge(null), same(base));
      expect(base.merge(const BoxStyle()), base);
    });

    test('copyWith replaces only the given tokens', () {
      const style = BoxStyle(direction: Axis.horizontal, gap: 4);

      final copy = style.copyWith(gap: 8, flex: 1);

      expect(copy.direction, Axis.horizontal);
      expect(copy.gap, 8);
      expect(copy.flex, 1);
      expect(copy, isNot(style));
    });

    test('merges text styles token by token', () {
      const base = BoxStyle(
        textStyle: BoxTextStyle(fontSize: 16, color: BoxColor.black),
      );
      const overlay = BoxStyle(textStyle: BoxTextStyle(color: BoxColor.white));

      final merged = base.merge(overlay);

      expect(merged.textStyle?.fontSize, 16);
      expect(merged.textStyle?.color, BoxColor.white);
    });

    test('keeps the text style when the overlay has none', () {
      const style = BoxStyle(textStyle: BoxTextStyle(fontSize: 16));

      expect(style.merge(const BoxStyle(gap: 8)).textStyle, style.textStyle);
      expect(const BoxStyle(gap: 8).merge(style).textStyle, style.textStyle);
    });

    test('implements value equality', () {
      const style = BoxStyle(
        direction: Axis.vertical,
        mainAlign: MainAlign.spaceBetween,
        crossAlign: CrossAlign.stretch,
        overflow: Overflow.scroll,
        padding: BoxSpacing.all(8),
        border: BoxBorder(width: 1),
        shadow: BoxShadow(),
        textStyle: BoxTextStyle(fontSize: 16),
      );

      expect(style, style.copyWith());
      expect(style.hashCode, style.copyWith().hashCode);
      expect(style, isNot(style.copyWith(mainAlign: MainAlign.center)));
      expect(
        style,
        isNot(style.copyWith(textStyle: BoxTextStyle(fontSize: 18))),
      );
      expect(style.toString(), contains('direction: Axis.vertical'));
      expect(style.toString(), contains('textStyle'));
    });
  });

  group('BoxTextStyle', () {
    test('starts empty', () {
      expect(const BoxTextStyle().isEmpty, isTrue);
      expect(const BoxTextStyle(fontSize: 16).isEmpty, isFalse);
    });

    test('stores every typography token', () {
      const style = BoxTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.semiBold,
        color: BoxColor.black,
        lineHeight: 1.5,
        fontFamily: 'Inter',
        letterSpacing: 0.2,
      );

      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.semiBold);
      expect(style.color, BoxColor.black);
      expect(style.lineHeight, 1.5);
      expect(style.fontFamily, 'Inter');
      expect(style.letterSpacing, 0.2);
    });

    test('merge lets the overlay win', () {
      const base = BoxTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: BoxColor.black,
      );
      const overlay = BoxTextStyle(color: BoxColor.white, lineHeight: 1.4);

      final merged = base.merge(overlay);

      expect(merged.fontSize, 16);
      expect(merged.fontWeight, FontWeight.normal);
      expect(merged.color, BoxColor.white);
      expect(merged.lineHeight, 1.4);
    });

    test('merge keeps the base when the overlay is null or empty', () {
      const base = BoxTextStyle(fontSize: 16);

      expect(base.merge(null), same(base));
      expect(base.merge(const BoxTextStyle()), base);
    });

    test('copyWith replaces only the given tokens', () {
      const style = BoxTextStyle(fontSize: 16, color: BoxColor.black);

      final copy = style.copyWith(fontWeight: FontWeight.bold);

      expect(copy.fontSize, 16);
      expect(copy.color, BoxColor.black);
      expect(copy.fontWeight, FontWeight.bold);
      expect(copy, isNot(style));
    });

    test('implements value equality', () {
      const style = BoxTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: BoxColor.black,
        lineHeight: 1.5,
        fontFamily: 'Inter',
        letterSpacing: 0.2,
      );

      expect(style, style.copyWith());
      expect(style.hashCode, style.copyWith().hashCode);
      expect(style, isNot(style.copyWith(fontSize: 18)));
      expect(style.toString(), contains('fontSize: 16.0'));
      expect(style.toString(), contains('fontFamily: Inter'));
    });
  });

  group('BoxSemantics', () {
    test('describes a plain container by default', () {
      const semantics = BoxSemantics();

      expect(semantics.role, BoxRole.none);
      expect(semantics.label, isNull);
      expect(semantics.checked, isNull);
      expect(semantics.isFocusable, isFalse);
    });

    test('states what a screen reader announces', () {
      const semantics = BoxSemantics(
        role: BoxRole.checkbox,
        label: 'Release notes',
        checked: true,
      );

      expect(semantics.role, BoxRole.checkbox);
      expect(semantics.label, 'Release notes');
      expect(semantics.checked, isTrue);
      expect(semantics.isFocusable, isTrue);
    });

    test('makes only the roles the user can act on focusable', () {
      expect(BoxRole.none.isInteractive, isFalse);
      expect(BoxRole.heading.isInteractive, isFalse);
      expect(BoxRole.button.isInteractive, isTrue);
      expect(BoxRole.checkbox.isInteractive, isTrue);
      expect(BoxRole.switch_.isInteractive, isTrue);
      expect(BoxRole.link.isInteractive, isTrue);
    });

    test('copyWith replaces only the given fields', () {
      const semantics = BoxSemantics(role: BoxRole.button, label: 'Submit');

      final copy = semantics.copyWith(role: BoxRole.link);

      expect(copy.role, BoxRole.link);
      expect(copy.label, 'Submit');
      expect(copy, isNot(semantics));
    });

    test('implements value equality', () {
      const semantics = BoxSemantics(
        role: BoxRole.switch_,
        label: 'Newsletter',
        checked: false,
      );

      expect(semantics, semantics.copyWith());
      expect(semantics.hashCode, semantics.copyWith().hashCode);
      expect(semantics, isNot(semantics.copyWith(checked: true)));
      expect(semantics.toString(), contains('role: BoxRole.switch_'));
      expect(semantics.toString(), contains('checked: false'));
    });
  });
}
