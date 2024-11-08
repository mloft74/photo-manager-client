import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/extensions/flatmap_extension.dart';

part 'displayable.freezed.dart';

/// Something that can be turned into a human readable representation.
// This is explicitly so that objects could be passed around, not functions.
// ignore: one_member_abstracts
abstract interface class Displayable {
  /// Returns a human readable representation of this object.
  Iterable<String> toDisplay();
}

@freezed
sealed class DefaultDisplayable
    with _$DefaultDisplayable
    implements Displayable {
  const DefaultDisplayable._();
  const factory DefaultDisplayable(IList<String> display) = _DefaultDisplayable;

  @override
  Iterable<String> toDisplay() => display;
}

@freezed
sealed class CompoundDisplayable with _$CompoundDisplayable implements Displayable{
  const CompoundDisplayable._();
  const factory CompoundDisplayable(IList<Displayable> displays) = _CompoundDisplayable;

  @override
  Iterable<String> toDisplay() => displays.flatMap((d) => d.toDisplay());
}

extension DisplayableExt on Displayable {
  /// Returns a human readable representation of this object.
  ///
  /// The lines are joined by newline characters.
  String toDisplayJoined() => toDisplay().join('\n');
}
