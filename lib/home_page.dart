import 'package:assistant/feature_box.dart';
import 'package:assistant/api_services.dart';
import 'package:assistant/pallete.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  GeminiService gemini = GeminiService();

  final SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  bool _isMicOn = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    print("started listening");
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isMicOn = true;
    });
  }

  Future<void> _stopListening() async {
    print("stopped");
    await _speechToText.stop();
    setState(() {
      _isMicOn = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.only(top: 16),
          child: const Text(
            "Bujji",
            style: TextStyle(
                fontSize: 35,
                fontFamily: 'Cera Pro',
                fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //assistant image with circular background
            const SizedBox(
              height: 25,
            ),
            Stack(
              children: [
                Center(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                    height: 130,
                    width: 130,
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 135,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/virtualAssistant.png'),
                    ),
                  ),
                )
              ],
            ),

            //chat bubble box

            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor,
                ),
                borderRadius:
                    BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
              ),
              child: const Text(
                "Good Morning, what task can I do for you?",
                style: TextStyle(
                  fontSize: 28,
                  color: Pallete.mainFontColor,
                  fontFamily: 'Cera Pro',
                ),
              ),
            ),

            //suggestion text
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
              child: const Text(
                "Here are a few features.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Cera Pro',
                ),
              ),
            ),

            const Column(
              children: [
                FeatureBox(
                  color: Pallete.firstSuggestionBoxColor,
                  title: 'Gemini',
                  description:
                      'A smarter way to stay organized and informed with Google Gemini',
                ),
                FeatureBox(
                  color: Pallete.secondSuggestionBoxColor,
                  title: 'LimeWire ',
                  description:
                      'Get inspired and stay creative with your personal assistant powered with Limewire',
                ),
                FeatureBox(
                  color: Pallete.thirdSuggestionBoxColor,
                  title: 'Voice Assistant',
                  description:
                      'Get the best of both worlds with a voice assistant powered by Gemini',
                ),
              ],
            ),
            Card(
                margin: const EdgeInsets.all(30),
                child: Text(
                  '$_lastWords is printed or not',
                  style: const TextStyle(color: Colors.red),
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await _speechToText.hasPermission &&
              _speechToText.isNotListening) {
            await _startListening();
          } else if (_speechToText.isListening) {
            final res = await gemini.isImagePrompt(_lastWords);
            print(res);

            await _stopListening();
          } else {
            _initSpeech();
          }
        },
        backgroundColor: _isMicOn
            ? const Color.fromARGB(255, 46, 184, 65)
            : Pallete.firstSuggestionBoxColor,
        child: const Icon(Icons.mic),
      ),
    );
  }
}
