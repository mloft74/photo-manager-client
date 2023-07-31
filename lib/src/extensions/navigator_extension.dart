import 'dart:async';

import 'package:flutter/widgets.dart';

extension NavigatorExtension on NavigatorState {
  () pushUnawaited(Route<()> route) {
    unawaited(push(route));
    return ();
  }
}
