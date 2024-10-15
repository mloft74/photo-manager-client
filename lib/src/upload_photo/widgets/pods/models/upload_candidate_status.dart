import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';

part 'upload_candidate_status.freezed.dart';

@freezed
sealed class UploadCandidateStatus with _$UploadCandidateStatus {
  const factory UploadCandidateStatus.pending() = Pending;
  const factory UploadCandidateStatus.uploading() = Uploading;
  const factory UploadCandidateStatus.uploaded() = Uploaded;
  const factory UploadCandidateStatus.uploadError(ErrorTrace errorTrace) = UploadError;
}
