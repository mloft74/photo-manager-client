import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  MaterialPageRoute<T> materialPageRoute<T>() =>
      MaterialPageRoute(builder: (context) => this);
}
