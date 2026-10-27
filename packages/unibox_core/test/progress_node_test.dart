import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';

void main() {
  group('ProgressNode', () {
    test('is indeterminate until it is given a value', () {
      const node = ProgressNode();

      expect(node.isIndeterminate, isTrue);
      expect(node.value, isNull);
      expect(node.size, 48);
      expect(node.strokeWidth, 4);
      expect(node.color, ProgressNode.defaultColor);
      expect(node.trackColor, BoxColor.transparent);
      expect(node.children, isEmpty);
    });

    test('is determinate with a value', () {
      const node = ProgressNode(value: 0.25, semanticsLabel: 'Uploading');

      expect(node.isIndeterminate, isFalse);
      expect(node.value, 0.25);
      expect(node.semanticsLabel, 'Uploading');
    });

    test('rejects a value outside zero to one', () {
      expect(() => ProgressNode(value: 1.5), throwsA(isA<AssertionError>()));
      expect(() => ProgressNode(value: -0.1), throwsA(isA<AssertionError>()));
    });

    test('validates as a tree', () {
      expect(validateTree(const ProgressNode()), isEmpty);
    });
  });
}
