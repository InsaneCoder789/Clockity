import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class TimerTab extends StatefulWidget {
  @override
  _TimerTabState createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;

  int _totalSeconds = 0;
  int _remainingSeconds = 0;

  Timer? _timer;
  bool _isRunning = false;

  void _startTimer() {
    _totalSeconds = (_hours * 3600) + (_minutes * 60) + _seconds;
    _remainingSeconds = _totalSeconds;

    if (_totalSeconds > 0) {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
          }
        });
      });
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
    });
  }

  void _setPreset(int seconds) {
    _timer?.cancel();
    setState(() {
      _hours = seconds ~/ 3600;
      _minutes = (seconds % 3600) ~/ 60;
      _seconds = seconds % 60;
      _isRunning = false;
      _remainingSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.purpleAccent),
                  SizedBox(width: 8),
                  Text(
                    "Timer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isRunning) ...[
              SizedBox(height: 20),
              // large sci-fi style pickers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSciFiPicker("HRS", 0, 23, _hours, (val) {
                    setState(() {
                      _hours = val;
                    });
                  }),
                  _buildSciFiPicker("MIN", 0, 59, _minutes, (val) {
                    setState(() {
                      _minutes = val;
                    });
                  }),
                  _buildSciFiPicker("SEC", 0, 59, _seconds, (val) {
                    setState(() {
                      _seconds = val;
                    });
                  }),
                ],
              ),
              SizedBox(height: 30),
              // quick presets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _presetButton("Break", 5 * 60),
                  _presetButton("15 min", 15 * 60),
                  _presetButton("Study", 30 * 60),
                ],
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  "START",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 30),
            ] else ...[
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: _remainingSeconds / _totalSeconds,
                          strokeWidth: 12,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                          backgroundColor: Colors.grey.shade800,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${(_totalSeconds / 60).round()} min",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16),
                          ),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                                fontSize: 48,
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Ends at ${TimeOfDay.now().replacing(minute: (TimeOfDay.now().minute + _remainingSeconds ~/ 60) % 60).format(context)}",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text(
                      "DELETE",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pauseTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text(
                      "PAUSE",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ]
          ],
        ),
      ),
    );
  }

  Widget _presetButton(String label, int seconds) {
    return GestureDetector(
      onTap: () => _setPreset(seconds),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.purpleAccent, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                _formatTime(seconds),
                style: TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSciFiPicker(String label, int min, int max, int selected,
      ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.5),
        ),
        SizedBox(
          height: 180,
          width: 90,
          child: CupertinoPicker(
            scrollController:
                FixedExtentScrollController(initialItem: selected),
            backgroundColor: Colors.black,
            itemExtent: 50,
            onSelectedItemChanged: onChanged,
            children: List.generate(
              max - min + 1,
              (index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'RobotoMono',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
