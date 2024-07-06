import 'dart:convert';

import 'package:assistant/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $OpenAIAPIKEY",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-1106",
          "messages": [
            {
              "role": "user",
              "content":
                  "Does this message want to generate an AI picture, image, art or something similar?, Simply answer in yes or no."
            },
          ]
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print("yayyyyyy");
      }
      return "AI";
    } catch (err) {
      return err.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    return "chatpgpt";
  }

  Future<String> dallEAPI(String prompt) async {
    return "Dall-E";
  }
}
