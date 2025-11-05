// lib/src/services/message_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MessageStorage {
  static const String _key = 'messages_list';

  Future<List<Map<String, dynamic>>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(messages));
  }

  Future<void> addMessage(Map<String, dynamic> message) async {
    final list = await loadMessages();
    list.add(message);
    await saveMessages(list);
  }

  Future<List<Map<String, dynamic>>> getMessagesForStudent(String? studentId) async {
    final all = await loadMessages();
    if (studentId == null) {
      // Broadcast messages
      return all.where((m) => m['isBroadcast'] == true).toList();
    }
    // Messages for specific student or broadcast
    return all.where((m) => 
      m['toId'] == studentId || m['isBroadcast'] == true
    ).toList();
  }
}

