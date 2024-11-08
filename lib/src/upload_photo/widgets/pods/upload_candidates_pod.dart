import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/models/upload_candidates_state.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_photo_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_candidates_pod.g.dart';

const _maxConcurrentUploads = 4;

enum UploadError implements Displayable {
  noCandidates,
  uploadInProgress,
  ;

  @override
  Iterable<String> toDisplay() => [name];
}

@riverpod
class UploadCandidates extends _$UploadCandidates {
  @override
  UploadCandidatesState build() {
    return const UploadCandidatesState(
      loading: false,
      statuses: IMapConst({}),
    );
  }

  Future<()> updateStatuses(
    FutureOr<UploadCandidateStatuses?> Function() fn,
  ) async {
    state = state.copyWith(loading: true);

    final res = fn();
    final newStatuses = res is UploadCandidateStatuses? ? res : await res;
    if (newStatuses == null) {
      state = state.copyWith(loading: false);
    } else {
      state = UploadCandidatesState(loading: false, statuses: newStatuses);
    }

    return ();
  }

  IList<String> _candidates = const IListConst([]);
  var _completer = Completer<()>();
  // This function and related functions are a mess, but I'm not fixing it right now.
  Future<Result<IMap<String, Result<(), UploadPhotoError>>, UploadError>>
      upload() async {
    if (state.statuses.isEmpty) {
      return const Err(UploadError.noCandidates);
    }
    if (_ops.isNotEmpty || _candidates.isNotEmpty) {
      return const Err(UploadError.uploadInProgress);
    }

    _completer = Completer();

    _candidates = IList(state.statuses.keys.toList().reversedView);
    _ops = const IMapConst({});
    _results = const IMapConst({});

    for (var i = 0; i < _maxConcurrentUploads; ++i) {
      if (_candidates.isEmpty) {
        break;
      }
      _startUpload();
    }

    await _completer.future;

    return Ok(_results);
  }

  () _startUpload() {
    if (_candidates.isEmpty) {
      return ();
    }
    final candidateOut = Output<String>();
    _candidates = _candidates.removeLast(candidateOut);
    final candidate = candidateOut.value!;
    // Not discarded.
    // ignore: discarded_futures
    _ops = _ops.add(candidate, _upload(candidate));

    return ();
  }

  IMap<String, Future<()>> _ops = const IMapConst({});
  IMap<String, Result<(), UploadPhotoError>> _results = const IMapConst({});
  Future<()> _upload(String candidate) async {
    final maybeUpload = ref.read(uploadPhotoPod);
    if (maybeUpload.isNone) {
      ref.read(logsPod.notifier).logError(
            LogTopic.photoUpload,
            const DefaultDisplayable(
              IListConst(['No server selected when uploading photos']),
            ),
          );
      return ();
    }

    state = state
        .mapStatuses((s) => s.add(candidate, UploadCandidateStatus.uploading));
    final upload = maybeUpload.expect('Should have checked for None earlier');
    final res = await upload(candidate);

    _ops = _ops.remove(candidate);
    _startUpload();

    _results = _results.add(candidate, res);
    final fileName = candidate.split('/').last;
    switch (res) {
      case Ok():
        ref.read(logsPod.notifier).logInfo(
              LogTopic.photoUpload,
              DefaultDisplayable(
                IList(['Successfully uploaded $fileName']),
              ),
            );
        state = state.mapStatuses(
          (s) => s.add(candidate, UploadCandidateStatus.uploaded),
        );
      case Err(error: ImageAlreadyExists()):
        ref.read(logsPod.notifier).logInfo(
              LogTopic.photoUpload,
              DefaultDisplayable(
                IList(['Candidate $fileName already exists on server']),
              ),
            );
        state = state.mapStatuses(
          (s) => s.add(candidate, UploadCandidateStatus.imageAlreadyExists),
        );
      case Err(:final error):
        ref.read(logsPod.notifier).logError(
              LogTopic.photoUpload,
              CompoundDisplayable(
                IList([
                  DefaultDisplayable(
                    IList(['Failed to upload $fileName']),
                  ),
                  error,
                ]),
              ),
            );
        state = state
            .mapStatuses((s) => s.add(candidate, UploadCandidateStatus.error));
    }

    if (_ops.isEmpty) {
      _completer.complete(());
    }

    return ();
  }
}
