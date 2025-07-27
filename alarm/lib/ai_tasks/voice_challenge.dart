// lib/screens/voice_challenge_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:alarm/widgets/animated_space_background.dart';

class VoiceChallengeScreen extends StatefulWidget {
  const VoiceChallengeScreen({super.key});

  @override
  State<VoiceChallengeScreen> createState() => _VoiceChallengeScreenState();
}

class _VoiceChallengeScreenState extends State<VoiceChallengeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final String _targetPhrase = 'The stars guide my morning mission';
  final String _status = '';
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.2); // High pitch for futuristic tone
    await _flutterTts.setSpeechRate(0.45); // Clear and slow
  }

  Future<void> _speakPhrase() async {
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(_targetPhrase);
    await Future.delayed(const Duration(seconds: 2)); // wait to finish
    setState(() => _isSpeaking = false);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AnimatedSpaceBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('🛰️ Voice Challenge'),
            backgroundColor: Colors.transparent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Memorize this phrase:',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  '"$_targetPhrase"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _isSpeaking ? null : _speakPhrase,
                  icon: const Icon(Icons.volume_up),
                  label: Text(_isSpeaking ? 'Speaking...' : 'Speak it'),
                ),
                const SizedBox(height: 20),
                if (_status.isNotEmpty)
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 18,
                      color: _status.contains('✅') ? Colors.greenAccent : Colors.redAccent,
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
