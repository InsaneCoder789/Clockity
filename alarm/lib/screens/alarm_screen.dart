import 'package:flutter/material.dart';
import 'alarm_tab.dart';
import 'timer_tab.dart';
import 'world_clock_tab.dart';
import 'stopwatch_tab.dart';

class ClockApp extends StatefulWidget {
  const ClockApp({super.key});

  @override
  State<ClockApp> createState() => _ClockAppState();
}

class _ClockAppState extends State<ClockApp> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const AlarmTab(),
    const WorldClockTab(),
    TimerTab(),
    const StopwatchTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.deepPurpleAccent,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm),
                label: 'Alarm',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.language),
                label: 'World Clock',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer),
                label: 'Timer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.av_timer),
                label: 'Stopwatch',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
