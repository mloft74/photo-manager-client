import 'package:image_picker/image_picker.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo.g.dart';

typedef PhotoState = Option<XFile>;

@riverpod
class Photo extends _$Photo {
  @override
  FutureOr<PhotoState> build() {
    return const None();
  }

  // No getter will be provided.
  // ignore: use_setters_to_change_properties
  Future<void> updateAsync(Future<PhotoState> Function() fn) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fn);
  }
}
