import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterAPI {

  // 🔴 Put your Gemini API key here
  static const String _apiKey =
      "AIzaSyCau2MZvRS3FG_18eCkLouSsi-oVQY4XJc";

  static const String _url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$_apiKey";

  /// Accepts prompt from home.dart and returns Gemini reply
  static Future<String> getReply(String prompt) async {

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String aiText =
      data['candidates'][0]['content']['parts'][0]['text'];

      // formatting cleanup (same as before)
      aiText = aiText
          .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
          .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
          .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '')
          .split(RegExp(r'(?<=[.!?])\s+'))
          .join('\n');

      return aiText;
    } else {
      print(response.body);
      throw Exception("Gemini API error");
    }
  }
}