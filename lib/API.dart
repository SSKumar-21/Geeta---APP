import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterAPI {
  static const String _apiKey = "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";

  static const String _model = "deepseek/deepseek-r1-0528:free";

  static const String _url = "https://openrouter.ai/api/v1/chat/completions";

  /// Accepts user prompt and returns AI reply text
  static Future<String> getReply(String prompt) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
        // "HTTP-Referer": "https://yourapp.com",
        // "X-Title": "Geeta AI Flutter App",
      },
      body: jsonEncode({
        "model": _model,
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "stream": false
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String aiText = data['choices'][0]['message']['content'];

      // ---- CLEAN FORMATTING (same as your JS) ----
      aiText = aiText
          .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
          .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
          .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '')
          .split(RegExp(r'(?<=[.!?])\s+'))
          .join('\n');

      return aiText;
    } else {
      throw Exception("OpenRouter API error");
    }
  }
}
