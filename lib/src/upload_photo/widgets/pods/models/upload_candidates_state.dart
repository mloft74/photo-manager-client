import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_candidates_state.freezed.dart';

enum UploadCandidateStatus {
  pending,
  uploading,
  uploaded,
  imageAlreadyExists,
  error,
}

typedef UploadCandidateStatuses = IMap<String, UploadCandidateStatus>;

@freezed
sealed class UploadCandidatesState with _$UploadCandidatesState {
  const UploadCandidatesState._();

  const factory UploadCandidatesState({
    required bool loading,
    required UploadCandidateStatuses statuses,
  }) = _UploadCandidatesState;

  UploadCandidatesState mapStatuses(UploadCandidateStatuses Function(UploadCandidateStatuses statuses) fn) =>
      UploadCandidatesState(loading: loading, statuses: fn(statuses));
}
