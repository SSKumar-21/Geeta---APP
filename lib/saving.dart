import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorage {
  static const String _chatKey = 'chat_history';

  /// 💾 Append messages to history
  static Future<void> saveConversation(
      List<Map<String, dynamic>> conversation) async {
    final prefs = await SharedPreferences.getInstance();

    String encodedData = jsonEncode(conversation);
    await prefs.setString(_chatKey, encodedData);
  }

  /// 📖 Load full chat history
  static Future<List<Map<String, dynamic>>> loadConversation() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_chatKey);

    if (data == null) return [];

    List decoded = jsonDecode(data);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// ❌ Clear saved history (optional use)
  static Future<void> clearConversation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatKey);
  }
}
