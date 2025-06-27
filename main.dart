import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MaterialApp(home: VoiceTranslator()));
}

class VoiceTranslator extends StatefulWidget {
  const VoiceTranslator({super.key});

  @override
  State<VoiceTranslator> createState() => _VoiceTranslatorState();
}

class _VoiceTranslatorState extends State<VoiceTranslator> {
  late stt.SpeechToText speech;
  bool isListening = false;
  String recognizedText = 'Press the mic to start';
  String translatedText = '';
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  Future<void> startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (result) async {
          setState(() {
            recognizedText = result.recognizedWords;
          });

          if (recognizedText.isNotEmpty) {
            var translation = await translator.translate(
              recognizedText,
              to: 'fr',
            );
            setState(() {
              translatedText = translation.text;
            });
            await flutterTts.speak(translatedText);
          }
        },
      );
    }
  }

  void stopListening() {
    setState(() => isListening = false);
    speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GUEST Voice Translator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(recognizedText),
            const SizedBox(height: 20),
            const Text('Translated Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(translatedText, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isListening ? stopListening : startListening,
              child: Text(isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}