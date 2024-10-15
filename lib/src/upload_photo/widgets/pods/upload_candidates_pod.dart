import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/models/upload_candidate_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_candidates_pod.g.dart';

typedef UploadCandidatesState = IMap<String, UploadCandidateStatus>;

@riverpod
class UploadCandidates extends _$UploadCandidates {
  @override
  UploadCandidatesState build() {
    return const IMapConst({});
  }

  () updateState(UploadCandidatesState newState) {
    state = newState;
    return ();
  }
}
