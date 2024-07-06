import 'package:assistant/secrets.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiStoryPage extends StatefulWidget {
  const GeminiStoryPage({super.key});

  @override
  State<GeminiStoryPage> createState() => _GeminiStoryPageState();
}

class _GeminiStoryPageState extends State<GeminiStoryPage> {
  String? _generatedStory;

  final GenerativeModel _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: geminiAPI); // Replace with your actual key

  void _generateStory() async {
    final content = [Content.text('Write a story about a AI and magic')];
    final response = await _model.generateContent(content);

    setState(() {
      _generatedStory = response.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Story Generator'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _generateStory,
                child: const Text('Generate Story'),
              ),
              Text("Okay $_generatedStory"),
            ],
          ),
        ),
      ),
    );
  }
}
