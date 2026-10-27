import 'package:listen/listen.dart';
import 'package:meta/meta.dart';
import 'package:unibox_core/unibox_core.dart';

/// A [Store] that holds one state value and notifies its listeners when that
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
/// A subclass publishes by assigning [state]; the setter drops a value that is
/// `==` to the current one, so an unchanged description never rebuilds a tree.
/// The listeners are `package:listen`'s [ChangeNotifier] — the same class
/// Flutter keeps in `foundation`, in pure Dart — so a renderer on either target
/// subscribes to the store with `addListener`, and a server render reads
/// [state] without doing anything else.
///
/// [onMount] is the one lifecycle hook a renderer calls: start an initial
/// request there rather than in the constructor, so a server render can read
/// the first state without running it.
abstract class StateStore<S> extends ChangeNotifier implements Store<S> {
  /// Creates a store whose first state is [state].
  StateStore(this._state);

  S _state;

  @override
  S get state => _state;

  /// Replaces the state and notifies the listeners.
  ///
  /// Assigning a value equal to the current one does nothing, which keeps a
  /// rebuild tied to a change of the description rather than to a call.
  @protected
  set state(S next) {
    if (next == _state) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  @override
  void onMount() {}

  @override
  void onUnmount() {}
}
