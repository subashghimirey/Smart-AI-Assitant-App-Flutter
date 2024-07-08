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
          "$prompt Does this message want to generate an image, art or picture or something else? Only answer yes if the user wants to generate on image, picture art or something else, if user wants to know location, say no. Simply answer in yes or no only, no more words? Just say yes or no only.")
    ];

    try {
      final response = await _model.generateContent(content);
      bool isImage = containsYesOrNo(response.text!);
      
      if (isImage) {
        final response = await generateImage(prompt);
        // print("limewire api");
        return response!;
      } else {
        final response = await geminiAPI(prompt);
        
        return response;
      }
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

    final content = [
      Content.text(
          "${messages.toString()} Provide answer in exact 60 words only, only use english alphabets and numbers while answering. Do not use * and emojis.")
    ];
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
   

    const limeWireAPI = limeWireAPIKEY;

    final url = Uri.parse('https://api.limewire.com/api/image/generation');
    final headers = {
      "Content-Type": "application/json",
      "X-Api-Version": 'v1',
      "Accept": "application/json",
      "Authorization": "Bearer $limeWireAPI",
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
        return imageUrl;
      } else {
        
        switch (response.statusCode) {
          case 400:
            throw Exception('Bad request. Check your prompt or request body.');
          case 401:
            throw Exception('Unauthorized. Check your API key.');
          case 429:
            throw Exception('Rate limit exceeded. Reduce request frequency.');
          case 500:
            throw Exception('Internal server error. Try again later.');
          default:
            throw Exception('Error generating image: ${response.statusCode}');
        }
      }
    } catch (err) {
      
      return "error occured"; // 
    }
  }

  Future<String?> generateImage(String prompt) async {
    final url = Uri.parse('http://127.0.0.1:5000/generate-image');
    final headers = {
      "Content-Type": "application/json",
      "X-Api-Version": "v1",
      "Accept": "application/json",
      "Authorization": limeWireAPIKEY,
    };
    final body = jsonEncode({"prompt": prompt});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['image_url'];
        // print("Generated Image URL: $imageUrl");
        return imageUrl;
      } else {
        // print('Error generating image: ${response.statusCode}');
        // print(response.body);
        return null;
      }
    } catch (err) {
      // print('Error: $err');
      return null;
    }
  }
}
