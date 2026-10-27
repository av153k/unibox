/// The state a `StatefulNode` draws, and the way a renderer watches it.
///
/// A store owns one value and tells its listeners when that value is replaced.
/// It is the only mutable object a tree can introduce, and the node creates it
/// instead of holding it, so the tree itself stays a description that can be
/// rendered twice.
///
/// ```dart
/// final class Counter extends StateStore<int> {
///   Counter() : super(0);
///
///   void increment() => state = state + 1;
/// }
/// ```
///
/// The interface names no platform, so a store is the same object in Flutter, in
/// a browser and in a test. [StateStore] is the ready made implementation, and
/// it needs nothing outside this package.
abstract interface class Store<S> {
  /// The current state, the value a renderer passes back into the node's view.
  S get state;

  /// Registers [listener] to be called after every change of [state].
  ///
  /// A renderer subscribes once when it mounts the node and removes the same
  /// listener when it unmounts.
  void addListener(void Function() listener);

  /// Removes a listener registered with [addListener].
  void removeListener(void Function() listener);

  /// Called once, after a renderer has mounted the node and subscribed.
  ///
  /// Work that should run when the node appears — an initial request, a timer —
  /// starts here rather than in a constructor, so that a server render can read
  /// [state] without starting it. A renderer must not call this more than once
  /// for one store.
  void onMount();

  /// Called once, before the renderer disposes the store, while [state] is
  /// still valid.
  void onUnmount();

  /// Releases whatever the store holds, including its listeners.
  void dispose();
}
