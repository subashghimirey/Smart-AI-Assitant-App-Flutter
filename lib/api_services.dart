import 'dart:convert';

import 'package:assistant/secrets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

final GenerativeModel _model =
    GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiAPI);

bool containsYesOrNo(String input) {
  final yesRegex =
      RegExp(r'\b(yes|YES|Yes|yes. | Yes.)\b', caseSensitive: false);

  return yesRegex.hasMatch(input);
}

class GeminiService {
  Future<String> isImagePrompt(String prompt) async {
    final content = [
      Content.text(
          "$prompt Does this message want to generate an image, art or picture or something else? Simply answer in yes or no only, no more words? Just say yes or no only.")
    ];

    try {
      final response = await _model.generateContent(content);
      bool isImagePrompt = containsYesOrNo(response.text!);
      print(response.text);
      if (isImagePrompt) {
        final response = await limeWireAPI(prompt);
        print("limewire api");
        return response!;
      } else {
        final response = await geminiAPI(prompt);
        print("text only");
        return response;
      }
      return "Some internal error occured, please stay tuend";
    }
    // return "An internal error occured";
    catch (err) {
      return err.toString();
    }
  }

  List<Map<String, String>> messages = [];

  Future<String> geminiAPI(String prompt) async {
    String geminiResponse = '';

    messages.add({
      'role': "user",
      'prompt': prompt,
    });

    final content = [Content.text(messages.toString())];
    // final content = [Content.text(prompt)];

    try {
      final response = await _model.generateContent(content);
      geminiResponse = response.text!;
      // print(geminiResponse);

      messages.add({
        'role': 'assistant',
        'content': response.text!,
      });

      return geminiResponse;
    }
    // return "An internal error occured";
    catch (err) {
      return err.toString();
    }
  }

  Future<String?> limeWireAPI(String prompt) async {
    // Replace with your actual LimeWire API key

    final url = Uri.parse('https://api.limewire.com/api/image/generation');
    final headers = {
      "Content-Type": "application/json",
      "X-Api-Version": 'v1',
      "Accept": "application/json",
      "Authorization": "Bearer $limeWireAPIKEY",
    };
    final body = jsonEncode({
      "prompt": prompt,
      "aspect_ratio": "1:1",
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['asset_url'];
        print(data.toString());
        print(imageUrl);
        return imageUrl;
      } else {
        print('Error generating image: ${response.statusCode}');
        print(response.body);
        return null; // Or throw an appropriate exception
      }
    } catch (err) {
      print('Error: $err');
      print(err.toString());
      return "error occured"; // Or throw an appropriate exception
    }
  }
}
