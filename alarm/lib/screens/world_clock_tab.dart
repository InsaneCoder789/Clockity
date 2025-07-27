// lib/screens/world_clock_tab.dart
import 'package:flutter/material.dart';

class WorldClockTab extends StatelessWidget {
  const WorldClockTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('World Clock')),
      body: const Center(child: Text('World clocks coming soon...')),
    );
  }
}
