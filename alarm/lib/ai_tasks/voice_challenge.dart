import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:alarm/widgets/animated_space_background.dart';

class VoiceChallengeScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const VoiceChallengeScreen({super.key, required this.onSuccess});

  @override
  State<VoiceChallengeScreen> createState() => _VoiceChallengeScreenState();
}

class _VoiceChallengeScreenState extends State<VoiceChallengeScreen> {
  final FlutterTts _tts = FlutterTts();
  final String _phrase = 'The stars guide my morning mission';

  final String _apiKey = 'e15f7e6b9cfe65de85a264a3a34567efa27d6d94'; // 🔑 Replace this
  late Deepgram _deepgram;

  StreamSubscription<DeepgramListenResult>? _subscription;
  AudioRecorder? _recorder;
  bool _isListening = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _initTTS();
    _deepgram = Deepgram(_apiKey);
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.2);
    await _tts.setSpeechRate(0.45);
  }

  Future<void> _startListening() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      setState(() => _status = '❌ Microphone permission denied');
      return;
    }

    _recorder = AudioRecorder();

    final micStream = await _recorder!.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    final queryParams = {
      'encoding': 'linear16',
      'sample_rate': 16000,
      'language': 'en',
    };

    setState(() {
      _status = '🎙️ Listening...';
      _isListening = true;
    });

    final stream = _deepgram.listen.live(
      micStream,
      queryParams: queryParams,
    );

    _subscription = stream.listen((result) {
      final transcript = result.transcript ?? '';
      debugPrint('Deepgram Transcript: $transcript');

      if (transcript.toLowerCase().contains(_phrase.toLowerCase())) {
        _stopListening();
        setState(() => _status = '✅ Phrase matched!');
        Future.delayed(const Duration(seconds: 1), () {
          widget.onSuccess();
          Navigator.pop(context);
        });
      } else {
        setState(() => _status = '❌ Try again...');
      }
    }, onError: (err) {
      setState(() => _status = '❌ Error: $err');
    });
  }

  Future<void> _stopListening() async {
    await _subscription?.cancel();
    await _recorder?.stop();
    setState(() {
      _isListening = false;
      _status = 'Stopped';
    });
  }

  Future<void> _speakPhrase() async {
    await _tts.speak(_phrase);
  }

  @override
  void dispose() {
    _tts.stop();
    _stopListening();
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
            backgroundColor: Colors.transparent,
            title: const Text('🚀 Voice Challenge'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Speak this phrase to dismiss alarm:',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(
                  '"$_phrase"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _speakPhrase,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Hear Phrase'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                ),
                const SizedBox(height: 30),
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 18,
                    color: _status.contains('✅')
                        ? Colors.greenAccent
                        : (_status.contains('❌') ? Colors.redAccent : Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
