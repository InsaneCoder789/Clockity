import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/widgets/animated_space_background.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alarm_task_model.dart';
import '../providers/alarm_provider.dart' as alarm_providers;
import 'setup_screen.dart';
import 'package:alarm/ai_tasks/voice_challenge.dart';
import 'package:alarm/ai_tasks/face_detection.dart';
import 'package:alarm/ai_tasks/memory_test.dart';
import 'package:alarm/ai_tasks/object_detection.dart'; // <-- Import voice challenge

final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

class AlarmTab extends ConsumerStatefulWidget {
  const AlarmTab({super.key});
  @override
  ConsumerState<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends ConsumerState<AlarmTab> {
  @override
  void initState() {
    super.initState();
    _initAlarm();
  }

  Future<void> _initAlarm() async {
    await AndroidAlarmManager.initialize();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        if (res.payload != null && res.payload!.startsWith('alarm_')) {
          final index = int.tryParse(res.payload!.split('_')[1]);
          if (index != null && mounted) {
            _showAlarmPopup(context, index);
          }
        }
      },
    );
  }

  void _requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final intent =
          AndroidIntent(action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
      await intent.launch();
    }
  }

  String _formatTime(BuildContext context, int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  Future<void> _scheduleAlarm(AlarmModel alarm, int id) async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.hour,
      alarm.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final delay = scheduledTime.difference(now);

    await AndroidAlarmManager.oneShot(
      delay,
      id,
      () => _alarmCallback(id),
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> _alarmCallback(int id) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarms',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      ticker: 'Alarm',
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await fln.show(
      id,
      'Alarm Ringing',
      'Tap to dismiss or snooze',
      platformDetails,
      payload: 'alarm_$id',
    );
  }

  void _showAlarmPopup(BuildContext context, int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: const EdgeInsets.all(0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alarm, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "Wake up!",
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    final alarms = ref.read(alarm_providers.alarmListProvider);
                    final alarm = alarms[index];

                    if (alarm.dismissMethod.toLowerCase() == 'voice challenge') {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoiceChallengeScreen(
                            onSuccess: () async {
                              await AndroidAlarmManager.cancel(index);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text("Dismiss"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    AndroidAlarmManager.oneShot(
                      const Duration(minutes: 5),
                      index + 10000,
                      () => _alarmCallback(index),
                      exact: true,
                      wakeup: true,
                    );
                  },
                  icon: const Icon(Icons.snooze),
                  label: const Text("Snooze 5 min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarms = ref.watch(alarm_providers.alarmListProvider);
    final notifier = ref.read(alarm_providers.alarmListProvider.notifier);

    return Stack(
      children: [
        const AnimatedSpaceBackground(),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.7),
            appBar: AppBar(
              title: const Text('Alarms'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlarmSetupScreen(
                          alarmToEdit: alarm,
                          indexToEdit: index,
                        ),
                      ),
                    );

                    final updatedAlarm =
                        ref.read(alarm_providers.alarmListProvider)[index];
                    if (updatedAlarm.enabled) {
                      _requestExactAlarmPermission();
                      await _scheduleAlarm(updatedAlarm, index);
                    } else {
                      await AndroidAlarmManager.cancel(index);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.1),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTime(context, alarm.hour, alarm.minute),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alarm.label.isEmpty ? 'No Label' : alarm.label,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alarm.dismissMethod,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: alarm.enabled,
                          onChanged: (val) async {
                            notifier.toggleAlarm(index);
                            final updatedAlarm =
                                ref.read(alarm_providers.alarmListProvider)[index];
                            if (updatedAlarm.enabled) {
                              _requestExactAlarmPermission();
                              await _scheduleAlarm(updatedAlarm, index);
                            } else {
                              await AndroidAlarmManager.cancel(index);
                            }
                          },
                          activeColor: Colors.lightBlueAccent,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlarmSetupScreen()),
              ),
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}