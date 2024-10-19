const selectedServerKey = 'selected_server';
const logsPrefix = 'logs_';

/// Converts to UTC first.
String logsKeyForDate(DateTime date) {
  final utc = date.toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '$logsPrefix${year}_${month}_$day';
}
