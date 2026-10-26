/// The role a box plays for assistive technologies.
///
/// The roles are the ones both a screen reader and a browser expose, so a box
/// renders as a `Semantics` node in Flutter and as a `role` attribute on the
/// web. A role is also the opt in for keyboard focus: a box with a role the
/// user can act on becomes focusable, a box without one stays a plain
/// container and never lands in the tab order.
enum BoxRole {
  /// A plain container, the default.
  none,

  /// Something the user can press.
  button,

  /// A checkbox, usually paired with `BoxSemantics.checked`.
  checkbox,

  /// A switch, the on/off sibling of [checkbox].
  ///
  /// Carries a trailing underscore because `switch` is a reserved word.
  switch_,

  /// A link region that is not a `LinkNode`, for example an icon that opens a
  /// page in a new context.
  link,

  /// A heading; structural, so it is not focusable.
  heading;

  /// Whether the role is something the user can act on.
  ///
  /// Those roles make a box keyboard focusable, [heading] and [none] do not.
  bool get isInteractive =>
      this == button || this == checkbox || this == switch_ || this == link;
}

/// The accessibility description of a box.
///
/// A box without semantics is a plain container: screen readers announce its
/// content and nothing else. Adding semantics is how a hand drawn control
/// becomes a real button, checkbox or link for a keyboard and a screen reader.
///
/// ```dart
/// const Button = Box(
///   onTap: submit,
///   semantics: BoxSemantics(role: BoxRole.button, label: 'Create account'),
/// );
/// ```
final class BoxSemantics {
  /// Creates a description for a box.
  const BoxSemantics({this.role = BoxRole.none, this.label, this.checked});

  /// What the box means to assistive technologies.
  final BoxRole role;

  /// The text a screen reader announces instead of the contents.
  ///
  /// Leave it `null` when the contents already say what the box does, so the
  /// label and the visible text cannot drift apart.
  final String? label;

  /// Whether a checkbox or a switch is on.
  final bool? checked;

  /// Whether a box with this description takes keyboard focus.
  bool get isFocusable => role.isInteractive;

  /// Creates a copy of this description with the given fields replaced.
  BoxSemantics copyWith({BoxRole? role, String? label, bool? checked}) {
    return BoxSemantics(
      role: role ?? this.role,
      label: label ?? this.label,
      checked: checked ?? this.checked,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BoxSemantics &&
      other.role == role &&
      other.label == label &&
      other.checked == checked;

  @override
  int get hashCode => Object.hash(role, label, checked);

  @override
  String toString() {
    final fields = <String>[
      'role: $role',
      if (label != null) 'label: $label',
      if (checked != null) 'checked: $checked',
    ];
    return 'BoxSemantics(${fields.join(', ')})';
  }
}
