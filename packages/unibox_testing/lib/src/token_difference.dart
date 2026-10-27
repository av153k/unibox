/// What one side of a difference did with a token: the record's `actual` field is
/// the presentation that was read back, `expected` the one the case asked for.
///
/// Shared by [BoxAppearance] and [TextAppearance], which both report a drift as a
/// map from the token that moved to the two values that disagree.
typedef TokenDifference = ({Object? actual, Object? expected});
