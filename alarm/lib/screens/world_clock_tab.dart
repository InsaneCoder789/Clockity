import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class WorldClockTab extends StatefulWidget {
  const WorldClockTab({super.key});

  @override
  State<WorldClockTab> createState() => _WorldClockTabState();
}

class _WorldClockTabState extends State<WorldClockTab> {
  late Timer _timer;
  late tz.Location _localLocation;
  List<tz.Location> _allLocations = [];
  List<String> _selectedZones = [];

  @override
  void initState() {
    super.initState();
    _localLocation = tz.local;
    _loadTimeZones();
    _loadSelectedZones();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  Future<void> _loadTimeZones() async {
    setState(() {
      _allLocations = tz.timeZoneDatabase.locations.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _loadSelectedZones() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedZones = prefs.getStringList('selected_zones') ?? [];
    });
  }

  Future<void> _addCity() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _buildCityPicker(),
    );
    if (result != null && !_selectedZones.contains(result)) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedZones.add(result);
        prefs.setStringList('selected_zones', _selectedZones);
      });
    }
  }

  String _formatTime(tz.TZDateTime time) =>
      DateFormat('hh:mm:ss a').format(time);

  String _prettifyZoneName(String name) {
    final parts = name.split('/');
    return parts.last.replaceAll('_', ' ');
  }

  String _offsetFromLocal(tz.TZDateTime time) {
    final local = tz.TZDateTime.now(_localLocation);
    final diff = time.difference(local);
    final isAhead = diff.isNegative ? false : true;
    final absDiff = diff.abs();
    final hours = absDiff.inHours;
    final mins = absDiff.inMinutes.remainder(60);
    if (hours == 0 && mins == 0) return "Local time zone";
    return isAhead
        ? "$hours hours ${mins > 0 ? '$mins min' : ''} ahead"
        : "$hours hours ${mins > 0 ? '$mins min' : ''} behind";
  }

  Widget _buildCityPicker() {
    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: _allLocations.length,
        itemBuilder: (context, index) {
          final loc = _allLocations[index];
          final name = _prettifyZoneName(loc.name);
          return ListTile(
            title: Text(name, style: const TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, loc.name),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localTime = tz.TZDateTime.now(_localLocation);
    final localZone = _prettifyZoneName(_localLocation.name);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('World Clock', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // TOP BIG CLOCK
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: Column(
              children: [
                Text(
                  DateFormat('hh:mm:ss a').format(localTime),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$localZone time",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // + BUTTON
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _addCity,
            ),
          ),
          // SELECTED ZONES
          Expanded(
            child: ListView.builder(
              itemCount: _selectedZones.length,
              itemBuilder: (context, index) {
                final zoneName = _selectedZones[index];
                final loc = tz.getLocation(zoneName);
                final time = tz.TZDateTime.now(loc);
                final prettyName = _prettifyZoneName(zoneName);
                final offset = _offsetFromLocal(time);
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: Text(prettyName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      offset,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(time),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.wb_sunny,
                            color: Colors.amber, size: 18), // placeholder
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
