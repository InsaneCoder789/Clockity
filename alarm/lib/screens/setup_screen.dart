import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm_task_model.dart';
import '../providers/alarm_provider.dart';

class AlarmSetupScreen extends ConsumerStatefulWidget {
  final AlarmModel? alarmToEdit;
  final int? indexToEdit;

  const AlarmSetupScreen({super.key, this.alarmToEdit, this.indexToEdit});

  @override
  ConsumerState<AlarmSetupScreen> createState() => _AlarmSetupScreenState();
}

class _AlarmSetupScreenState extends ConsumerState<AlarmSetupScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _labelController = TextEditingController();
  bool _repeat = false;
  bool _vibrate = true;
  String _selectedDismissMethod = 'Voice Challenge';

  final List<String> _dismissMethods = [
    'Voice Challenge',
    'Face + Eye Detection',
    'Memory Recall Test',
    'Object Detection',
    'Traditional Ring',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alarmToEdit != null) {
      final alarm = widget.alarmToEdit!;
      _selectedTime = TimeOfDay(hour: alarm.hour, minute: alarm.minute);
      _labelController.text = alarm.label;
      _repeat = alarm.repeat;
      _vibrate = alarm.vibrate;
      _selectedDismissMethod = alarm.dismissMethod;
    }
  }

  void _saveAlarm() {
    final alarm = AlarmModel(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      repeat: _repeat,
      vibrate: _vibrate,
      label: _labelController.text.trim(),
      dismissMethod: _selectedDismissMethod,
      enabled: true,
    );

    final notifier = ref.read(alarmListProvider.notifier);

    if (widget.alarmToEdit != null && widget.indexToEdit != null) {
      notifier.editAlarm(widget.indexToEdit!, alarm);
    } else {
      notifier.addAlarm(alarm);
    }

    Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          timePickerTheme: const TimePickerThemeData(
            dialHandColor: Colors.blueAccent,
            backgroundColor: Colors.black87,
            hourMinuteTextColor: Colors.white,
            dayPeriodTextColor: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Set Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    const Icon(Icons.edit, color: Colors.white24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _labelController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Label',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Repeat', style: TextStyle(color: Colors.white70)),
                const Spacer(),
                Switch(
                  value: _repeat,
                  onChanged: (val) => setState(() => _repeat = val),
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
            Row(
              children: [
                const Text('Vibrate', style: TextStyle(color: Colors.white70)),
                const Spacer(),
                Switch(
                  value: _vibrate,
                  onChanged: (val) => setState(() => _vibrate = val),
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDismissMethod,
              dropdownColor: Colors.black,
              decoration: InputDecoration(
                labelText: 'Dismiss Method',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: _dismissMethods.map((method) => DropdownMenuItem(
                value: method,
                child: Text(method),
              )).toList(),
              onChanged: (val) => setState(() => _selectedDismissMethod = val!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAlarm,
                child: const Text('Save Alarm'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
