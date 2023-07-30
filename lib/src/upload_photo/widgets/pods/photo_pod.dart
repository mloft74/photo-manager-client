import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_pod.g.dart';

typedef PhotoStateValue = String;
typedef PhotoState = Option<PhotoStateValue>;

@riverpod
class Photo extends _$Photo {
  @override
  FutureOr<PhotoState> build() {
    return const None();
  }

  Future<void> updateAsync(Future<PhotoState> Function() fn) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fn);
  }
}
