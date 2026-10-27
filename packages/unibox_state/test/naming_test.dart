import 'package:listen/listen.dart';
import 'package:test/test.dart';
import 'package:unibox_core/unibox_core.dart';
import 'package:unibox_state/unibox_state.dart';

/// Holds the package to the half of the naming rule a test can check.
///
/// This file imports `unibox_core`, `listen` and `unibox_state` without a
/// prefix and names what each one provides. If `unibox_state` re-exported
/// `listen` — putting `ChangeNotifier` into a file that already has it — or
/// re-exported the core tokens, the import would be ambiguous and this file
/// would not compile.
void main() {
  test('exports a store without re-exporting core or listen', () {
    final StateStore<int> store = _Counter();
    final Store<int> contract = store;
    final Listenable notifier = store;

    expect(contract.state, 1);
    expect(notifier, isA<ChangeNotifier>());
    expect(store, isA<StateStore<int>>());
  });
}

final class _Counter extends StateStore<int> {
  _Counter() : super(1);
}
