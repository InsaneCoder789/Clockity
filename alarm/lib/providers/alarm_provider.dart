import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm_task_model.dart';

class AlarmListNotifier extends StateNotifier<List<AlarmModel>> {
  void editAlarm(int index, AlarmModel updatedAlarm) {
    updateAlarm(index, updatedAlarm);
  }
  AlarmListNotifier() : super([]);

  void addAlarm(AlarmModel alarm) {
    state = [...state, alarm];
  }

  void updateAlarm(int index, AlarmModel updatedAlarm) {
    final updatedList = [...state];
    updatedList[index] = updatedAlarm;
    state = updatedList;
  }

  void toggleAlarm(int index) {
    final updatedList = [...state];
    updatedList[index] =
        AlarmModel(
          hour: updatedList[index].hour,
          minute: updatedList[index].minute,
          label: updatedList[index].label,
          dismissMethod: updatedList[index].dismissMethod,
          repeat: updatedList[index].repeat,
          enabled: !updatedList[index].enabled,
          vibrate: updatedList[index].vibrate,
        );
    state = updatedList;
  }
}

final alarmListProvider = StateNotifierProvider<AlarmListNotifier, List<AlarmModel>>(
  (ref) => AlarmListNotifier(),
);
