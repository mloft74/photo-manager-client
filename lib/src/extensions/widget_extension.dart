import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/extensions/navigator_extension.dart';

extension WidgetExtension on Widget {
  MaterialPageRoute<T> materialRoute<T>() =>
      MaterialPageRoute(builder: (context) => this);

  () pushMaterialRouteUnawaited(BuildContext context) =>
      Navigator.of(context).pushUnawaited(materialRoute());

  Future<Option<T>> pushMaterialRoute<T extends Object>(BuildContext context) =>
      Navigator.push<T>(context, materialRoute()).toFutureOption();
}
