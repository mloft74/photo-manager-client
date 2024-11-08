enum DateTimeComponent {
  year,
  month,
  day,
  hour,
  minute,
  second,
  millisecond,
  microsecond,
}

extension DateTimeKeepExtension on DateTime {
  // Specify the precision of the DateTime.
  // Convert to UTC or local before calling this.
  DateTime withPrecision(
    DateTimeComponent component,
  ) {
    return copyWith(
      year: year,
      month: component.index >= DateTimeComponent.month.index ? month : 0,
      day: component.index >= DateTimeComponent.day.index ? day : 0,
      hour: component.index >= DateTimeComponent.hour.index ? hour : 0,
      minute: component.index >= DateTimeComponent.minute.index ? minute : 0,
      second: component.index >= DateTimeComponent.second.index ? second : 0,
      millisecond: component.index >= DateTimeComponent.millisecond.index
          ? millisecond
          : 0,
      microsecond: component.index >= DateTimeComponent.microsecond.index
          ? microsecond
          : 0,
    );
  }
}
