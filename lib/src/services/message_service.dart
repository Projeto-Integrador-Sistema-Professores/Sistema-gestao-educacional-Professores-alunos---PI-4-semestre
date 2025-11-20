// lib/src/services/message_service.dart
import 'package:uuid/uuid.dart';
import 'api_client.dart';
import '../models/message.dart';

class MessageService {
  final ApiClient client;
  MessageService(this.client);

  Future<List<Message>> listMessages({String? studentId}) async {
    final path = studentId != null ? '/messages?studentId=$studentId' : '/messages';
    final res = await client.get(path);
    final items = (res.data['items'] as List).cast<Map<String, dynamic>>();
    return items.map((e) => Message.fromJson(e)).toList();
  }

  Future<Message> sendMessage({
    required String content,
    String? toStudentId,
    String? toStudentName,
    bool broadcast = false,
  }) async {
    final id = const Uuid().v4();
    final payload = {
      'id': id,
      'fromId': 'teacher', // ID do professor
      'content': content,
      'sentAt': DateTime.now().toIso8601String(),
      'isBroadcast': broadcast,
      if (toStudentId != null) 'toId': toStudentId,
      if (toStudentName != null) 'toName': toStudentName,
    };
    final res = await client.post('/messages', data: payload);
    return Message.fromJson(res.data['message']);
  }
}

