import 'dart:async';

import 'package:flutter/widgets.dart';

extension NavigatorExtension on NavigatorState {
  void pushUnawaited(Route<void> route) => unawaited(push(route));
}
