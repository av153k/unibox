import 'store.dart';

/// A [Store] that keeps one state value and notifies its listeners when that
/// value is replaced.
///
/// ```dart
/// final class SignupStore extends StateStore<SignupState> {
///   SignupStore() : super(const SignupState());
///
///   void setEmail(String email) => state = state.copyWith(email: email);
/// }
/// ```
///
/// A subclass publishes by assigning [state]; a value equal to the current one
/// notifies nobody, so a rebuild follows a change of the description rather
/// than a call. The listener list is this class's own, which is why the model
/// keeps its promise of no package dependencies and still offers the same
/// store on every target.
///
/// [onMount] is the one lifecycle hook a renderer calls: start an initial
/// request there rather than in the constructor, so a server render can read
/// the first state without running it.
abstract class StateStore<S> implements Store<S> {
  /// Creates a store whose first state is [state].
  StateStore(this._state);

  S _state;
  final List<void Function()> _listeners = <void Function()>[];

  bool _disposed = false;

  @override
  S get state => _state;

  /// Replaces the state and notifies the listeners.
  ///
  /// It is the way a subclass publishes. Assigning a value equal to the current
  /// one does nothing, and a store that has been disposed ignores the
  /// assignment, so work that finishes after its node is gone cannot rebuild
  /// anything.
  set state(S next) {
    if (_disposed || next == _state) {
      return;
    }
    _state = next;
    _notify();
  }

  @override
  void addListener(void Function() listener) {
    if (!_disposed) {
      _listeners.add(listener);
    }
  }

  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);

  @override
  void onMount() {}

  @override
  void onUnmount() {}

  @override
  void dispose() {
    _listeners.clear();
    _disposed = true;
  }

  /// Calls every listener once, in the order they were added.
  ///
  /// The pass runs over a copy, so a listener may add or remove listeners
  /// while it is being called without disturbing the call in progress.
  void _notify() {
    for (final void Function() listener in List<void Function()>.of(
      _listeners,
    )) {
      listener();
    }
  }
}
