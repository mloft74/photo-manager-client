import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/http/errors/basic_http_error.dart'
    as bhe;
import 'package:photo_manager_client/src/http/errors/general_http_error.dart'
    as ghe;

const _timedOutErrOption =
    Some('Operation timed out. Are you on the right network?');

Option<String> buildBasicTimedOutErrorMsg(bhe.BasicHttpError error) =>
    switch (error) {
      bhe.TimedOut() => _timedOutErrOption,
      _ => const None(),
    };

Option<String> buildGeneralTimedOutErrorMsg(ghe.GeneralHttpError error) =>
    switch (error) {
      ghe.TimedOut() => _timedOutErrOption,
      _ => const None(),
    };
