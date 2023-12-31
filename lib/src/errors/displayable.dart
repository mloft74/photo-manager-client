/// Something that can be turned into a human readable representation.
// This is explicitly so that objects could be passed around, not functions.
// ignore: one_member_abstracts
abstract interface class Displayable {
  /// Returns a human readable representation of this object.
  Iterable<String> toDisplay();
}

extension DisplayableExt on Displayable {
  /// Returns a human readable representation of this object.
  ///
  /// The lines are joined by newline characters.
  String toDisplayJoined() => toDisplay().join('\n');
}
