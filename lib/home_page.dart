import 'package:animate_do/animate_do.dart';
import 'package:assistant/feature_box.dart';
import 'package:assistant/api_services.dart';
import 'package:assistant/pallete.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shimmer/shimmer.dart';

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
  final FlutterTts flutterTts = FlutterTts();
  String _lastWords = '';
  bool _isMicOn = false;
  String? generatedImage;
  String? generatedContent;

  bool isGenerating = false;

  int start = 200;
  int delay = 200;

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
    // print("started listening");
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isMicOn = true;
    });
  }

  Future<void> _stopListening() async {
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

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.only(top: 16),
          child: BounceInDown(
            child: const Text(
              "Bujji",
              style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'Cera Pro',
                  fontWeight: FontWeight.bold),
            ),
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
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 0),
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
            ),

            //chat bubble box

            FadeInRight(
              child: Visibility(
                visible: generatedImage == null && isGenerating == false,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40)
                        .copyWith(top: 30),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Pallete.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(20)
                          .copyWith(topLeft: Radius.zero),
                    ),
                    child: Text(
                      generatedContent == null
                          ? "Good Morning, what task can I do for you?"
                          : generatedContent!,
                      style: TextStyle(
                        fontSize: generatedContent == null ? 28 : 18,
                        color: Pallete.mainFontColor,
                        fontFamily: 'Cera Pro',
                      ),
                    )),
              ),
            ),

            if (isGenerating)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: 400.0,
                  height: 400.0,
                  child: Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 47, 48, 47),
                    highlightColor: Colors.grey,
                    child: Image.network(
                      "https://filestore.community.support.microsoft.com/api/images/8f0f43e2-9444-46c1-a88e-9dc1d4d6442f?upload=true",
                    ),
                  ),
                ),
              ),

            if (generatedImage != null)
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(generatedImage!))),

            //suggestion text
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null &&
                    generatedImage == null &&
                    isGenerating == false,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                  child: const Text(
                    "Here are a few features.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: 'Cera Pro',
                    ),
                  ),
                ),
              ),
            ),

            Visibility(
              visible: generatedContent == null &&
                  generatedImage == null &&
                  isGenerating == false,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      title: 'Gemini',
                      description:
                          'A smarter way to stay organized and informed with Google Gemini',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      title: 'LimeWire ',
                      description:
                          'Get inspired and stay creative with your personal assistant powered with Limewire',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      title: 'Voice Assistant',
                      description:
                          'Get the best of both worlds with a voice assistant powered by Gemini',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + delay * 3),
        child: FloatingActionButton(
          onPressed: () async {
            if (await _speechToText.hasPermission &&
                _speechToText.isNotListening) {
              await _startListening();
            } else if (_speechToText.isListening) {
              setState(() {
                isGenerating = true;
              });
              final res = await gemini.isImagePrompt(_lastWords);
              setState(() {
                isGenerating = false;
              });
              setState(() {
                isGenerating = false;
              });

              if (res.contains('https')) {
                generatedImage = res;
                generatedContent = null;
              } else {
                generatedContent = res;
                generatedImage = null;

                await systemSpeak(generatedContent!);
              }

              await _stopListening();
            } else {
              _initSpeech();
            }
          },
          backgroundColor: Pallete.firstSuggestionBoxColor,
          child: _isMicOn ? const Icon(Icons.stop) : const Icon(Icons.mic),
        ),
      ),
    );
  }
}
