import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';

part 'error_trace.freezed.dart';

@freezed
class ErrorTrace<T extends Object> with _$ErrorTrace<T> implements Displayable {
  const ErrorTrace._();

  const factory ErrorTrace(
    T error, [
    @Default(None<StackTrace>()) Option<StackTrace> stackTrace,
  ]) = _ErrorTrace;

  @override
  Iterable<String> toDisplay() {
    return [
      'Error: $error',
      if (stackTrace case Some(:final value)) ...[
        'Stack trace',
        '$value',
      ],
    ];
  }
}
