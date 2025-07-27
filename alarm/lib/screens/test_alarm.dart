import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class TestAlarmScreen extends StatefulWidget {
  const TestAlarmScreen({super.key});

  @override
  State<TestAlarmScreen> createState() => _TestAlarmScreenState();
}

class _TestAlarmScreenState extends State<TestAlarmScreen> {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await notificationsPlugin.initialize(const InitializationSettings(android: androidSettings));

    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  Future<void> _scheduleTestAlarm() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(const Duration(seconds: 10));

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Alarm',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      fullScreenIntent: true,
    );

    await notificationsPlugin.zonedSchedule(
      999,
      'Test Alarm',
      'This is your test alarm!',
      scheduledTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Test Alarm"), backgroundColor: Colors.black),
      body: Center(
        child: ElevatedButton(
          onPressed: _scheduleTestAlarm,
          child: const Text("Schedule Test Alarm (10s)"),
        ),
      ),
    );
  }
}
