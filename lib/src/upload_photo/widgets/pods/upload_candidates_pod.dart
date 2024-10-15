import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_photo_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_candidates_pod.g.dart';

// TODO(mloft74): Add some kind of flag for loading images from the picker
typedef UploadCandidatesState = IMap<String, UploadCandidateStatus>;

enum UploadCandidateStatus {
  pending,
  uploading,
  uploaded,
  error,
}

const _maxConcurrentUploads = 4;

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

  IList<String> _candidates = const IListConst([]);
  () upload() {
    if (_candidates.isNotEmpty || _ops.isNotEmpty || state.isEmpty) {
      return ();
    }

    _candidates = IList(state.keys.toList().reversedView);
    _ops = const IMapConst({});

    for (var i = 0; i < _maxConcurrentUploads; ++i) {
      if (_candidates.isEmpty) {
        break;
      }
      _startUpload('upload');
    }

    return ();
  }

  () _startUpload(String from) {
    if (_candidates.isEmpty) {
      return();
    }
    final candidateOut = Output<String>();
    _candidates = _candidates.removeLast(candidateOut);
    final candidate = candidateOut.value!;
    // Not discarded.
    // ignore: discarded_futures
    _ops = _ops.add(candidate, _upload(candidate));
    print('[$from] current number of ops: ${_ops.length}, started: $candidate');

    return ();
  }

  IMap<String, Future<()>> _ops = const IMapConst({});
  Future<()> _upload(String candidate) async {
    final maybeUpload = ref.read(uploadPhotoPod);
    if (maybeUpload.isNone) {
      // TODO(mloft74): log error
      return ();
    }

    state = state.add(candidate, UploadCandidateStatus.uploading);
    //final upload = maybeUpload.expect('Should have checked for None earlier');
    //final res = await upload(candidate);
    await Future<void>.delayed(const Duration(seconds: 2));
    final res = Result<(), ()>.ok(());

    switch (res) {
      case Ok():
        state = state.add(candidate, UploadCandidateStatus.uploaded);
      case Err():
        // TODO(mloft74): log error
        state = state.add(candidate, UploadCandidateStatus.error);
    }

    _ops = _ops.remove(candidate);
    _startUpload('_upload');

    print('number of ops at end: ${_ops.length}, in: $candidate');

    return ();
  }
}
