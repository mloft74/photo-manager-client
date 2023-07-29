import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/extensions/navigator_extension.dart';

extension WidgetExtension on Widget {
  MaterialPageRoute<T> materialRoute<T>() =>
      MaterialPageRoute(builder: (context) => this);

  void pushMaterialRouteUnawaited(BuildContext context) =>
      Navigator.of(context).pushUnawaited(materialRoute());

  Future<T?> pushMaterialRoute<T>(BuildContext context) =>
      Navigator.push(context, materialRoute());
}
