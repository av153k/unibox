import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibox_core/unibox_core.dart' as core;

import 'support/harness.dart';

/// The center of the rendered root node.
Offset nodeCenter(WidgetTester tester) => tester.getCenter(find.byKey(nodeKey));

/// A box that shows a black background in [state] over a white resting one.
core.Box statedBox(
  core.BoxState state, {
  core.BoxSemantics? semantics,
  bool enabled = true,
  void Function()? onTap,
}) {
  return core.Box(
    width: 120,
    height: 48,
    enabled: enabled,
    onTap: onTap,
    semantics: semantics,
    backgroundColor: core.BoxColor.white,
    stateStyles: <core.BoxState, core.BoxStyle>{
      state: const core.BoxStyle(backgroundColor: core.BoxColor.black),
    },
  );
}

void main() {
  group('BoxState.hover', () {
    testWidgets('applies the hover style while the pointer is over the box', (
      tester,
    ) async {
      await pumpNode(tester, statedBox(core.BoxState.hover));
      expect(decorationOf(tester)?.color, const Color(0xFFFFFFFF));

      final TestGesture pointer = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);
      await pointer.moveTo(nodeCenter(tester));
      await tester.pump();

      expect(decorationOf(tester)?.color, const Color(0xFF000000));

      await pointer.moveTo(const Offset(400, 500));
      await tester.pump();

      expect(decorationOf(tester)?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('serves no hover to a disabled box', (tester) async {
      await pumpNode(tester, statedBox(core.BoxState.hover, enabled: false));

      expect(inNode(find.byType(MouseRegion)), findsNothing);
    });
  });

  group('BoxState.pressed', () {
    testWidgets('applies the pressed style while the box is held', (
      tester,
    ) async {
      await pumpNode(tester, statedBox(core.BoxState.pressed, onTap: _noop));

      final TestGesture gesture = await tester.startGesture(nodeCenter(tester));
      await tester.pump(kPressTimeout);

      expect(decorationOf(tester)?.color, const Color(0xFF000000));

      await gesture.up();
      await tester.pump();

      expect(decorationOf(tester)?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('stacks the hovered and the pressed style', (tester) async {
      await pumpNode(
        tester,
        const core.Box(
          width: 120,
          height: 48,
          onTap: _noop,
          backgroundColor: core.BoxColor.white,
          stateStyles: <core.BoxState, core.BoxStyle>{
            core.BoxState.hover: core.BoxStyle(borderRadius: 4),
            core.BoxState.pressed: core.BoxStyle(
              backgroundColor: core.BoxColor.black,
            ),
          },
        ),
      );

      final TestGesture pointer = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);
      await pointer.moveTo(nodeCenter(tester));
      await tester.pump();

      final TestGesture gesture = await tester.startGesture(
        nodeCenter(tester),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(kPressTimeout);

      final BoxDecoration? decoration = decorationOf(tester);
      expect(decoration?.color, const Color(0xFF000000));
      expect(decoration?.borderRadius, BorderRadius.circular(4));

      await gesture.up();
      await pointer.removePointer();
    });
  });

  group('BoxState.focus', () {
    testWidgets('takes focus and applies the focus style', (tester) async {
      await pumpMaterialNode(
        tester,
        statedBox(
          core.BoxState.focus,
          onTap: _noop,
          semantics: const core.BoxSemantics(
            role: core.BoxRole.button,
            label: 'Create account',
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(decorationOf(tester)?.color, const Color(0xFF000000));
    });

    testWidgets('stays out of the tab order without a role', (tester) async {
      await pumpMaterialNode(
        tester,
        statedBox(core.BoxState.focus, onTap: _noop),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(decorationOf(tester)?.color, const Color(0xFFFFFFFF));
    });
  });

  group('keyboard activation', () {
    testWidgets('activates a focused box with enter', (tester) async {
      int taps = 0;

      await pumpMaterialNode(
        tester,
        statedBox(
          core.BoxState.focus,
          onTap: () => taps++,
          semantics: const core.BoxSemantics(role: core.BoxRole.button),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('activates a focused box with space on key up', (tester) async {
      int taps = 0;

      await pumpMaterialNode(
        tester,
        statedBox(
          core.BoxState.pressed,
          onTap: () => taps++,
          semantics: const core.BoxSemantics(role: core.BoxRole.button),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(decorationOf(tester)?.color, const Color(0xFF000000));
      expect(taps, 0);

      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(taps, 1);
      expect(decorationOf(tester)?.color, const Color(0xFFFFFFFF));
    });
  });

  group('semantics', () {
    testWidgets('describes the role, the label and the checked state', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpNode(
        tester,
        const core.Box(
          semantics: core.BoxSemantics(
            role: core.BoxRole.checkbox,
            label: 'Release notes',
            checked: true,
          ),
          children: <core.UINode>[core.TextNode('Release notes')],
        ),
      );

      expect(
        tester.getSemantics(find.byKey(nodeKey)),
        isSemantics(
          label: 'Release notes',
          isChecked: true,
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('reports a disabled box and drops its callbacks', (
      tester,
    ) async {
      int taps = 0;
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpNode(
        tester,
        core.Box(
          enabled: false,
          onTap: () => taps++,
          semantics: const core.BoxSemantics(
            role: core.BoxRole.button,
            label: 'Create account',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byKey(nodeKey)),
        isSemantics(
          label: 'Create account',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      expect(
        tester
            .widget<GestureDetector>(inNode(find.byType(GestureDetector)))
            .onTap,
        isNull,
      );
      expect(taps, 0);

      handle.dispose();
    });
  });
}

void _noop() {}
