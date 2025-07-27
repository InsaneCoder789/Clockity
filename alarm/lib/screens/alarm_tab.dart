import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/widgets/animated_space_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'dart:ui';

import '../models/alarm_task_model.dart';
import '../providers/alarm_provider.dart' as alarm_providers;
import 'setup_screen.dart';

final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    fln.FlutterLocalNotificationsPlugin();

class AlarmTab extends ConsumerWidget {
  const AlarmTab({super.key});

  String _formatTime(BuildContext context, int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  Future<void> _scheduleAlarm(AlarmModel alarm, int id) async {
    final androidDetails = fln.AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Channel for Alarm notifications',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      playSound: true,
      fullScreenIntent: true,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Alarm - ${alarm.label.isEmpty ? 'Reminder' : alarm.label}',
      'Time to wake up!',
      _nextInstanceOfTime(alarm.hour, alarm.minute),
      fln.NotificationDetails(android: androidDetails),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: alarm.repeat ? fln.DateTimeComponents.time : null,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              centerTitle: true,
              titleTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
                shadows: [Shadow(color: Colors.blue, blurRadius: 10)],
              ),
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

                    final updatedAlarm = ref.read(alarm_providers.alarmListProvider)[index];
                    if (updatedAlarm.enabled) {
                      await _scheduleAlarm(updatedAlarm, index);
                    } else {
                      await flutterLocalNotificationsPlugin.cancel(index);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.1),
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
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.blueAccent, blurRadius: 6)],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alarm.label.isEmpty ? 'No Label' : alarm.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
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
                            final updatedAlarm = ref.read(alarm_providers.alarmListProvider)[index];
                            if (updatedAlarm.enabled) {
                              await _scheduleAlarm(updatedAlarm, index);
                            } else {
                              await flutterLocalNotificationsPlugin.cancel(index);
                            }
                          },
                          activeColor: Colors.cyanAccent,
                        )
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
              backgroundColor: Colors.cyanAccent.withOpacity(0.9),
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
