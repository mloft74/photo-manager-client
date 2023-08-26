import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_sorting_pod.g.dart';

@riverpod
class DateSorting extends _$DateSorting {
  @override
  DateSortingState build() {
    return DateSortingState.newToOld;
  }

  // The pod is the getter.
  // ignore: avoid_setters_without_getters
  set sorting(DateSortingState value) {
    state = value;
  }
}

enum DateSortingState {
  newToOld,
  oldToNew,
}
