import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';

part 'error_trace.freezed.dart';

@freezed
class ErrorTrace<T extends Object> with _$ErrorTrace<T> {
  const factory ErrorTrace(
    T error, [
    @Default(None<StackTrace>()) Option<StackTrace> stackTrace,
  ]) = _ErrorTrace;
}
