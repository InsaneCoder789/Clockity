class AlarmModel {
  final int hour;
  final int minute;
  final bool repeat;
  final bool vibrate;
  final String label;
  final String dismissMethod;
  final bool enabled;

  AlarmModel({
    required this.hour,
    required this.minute,
    required this.repeat,
    required this.vibrate,
    required this.label,
    required this.dismissMethod,
    required this.enabled,
  });
}