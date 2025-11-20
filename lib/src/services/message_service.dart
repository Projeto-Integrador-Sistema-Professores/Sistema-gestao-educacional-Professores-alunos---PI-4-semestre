// lib/src/services/message_service.dart
import 'api_client.dart';
import '../models/message.dart';
import 'auth_service.dart';

class MessageService {
  final ApiClient client;
  final AuthService authService;
  
  MessageService(this.client, this.authService);

  Future<List<Message>> listMessages({String? studentId}) async {
    try {
      final token = await authService.getToken();
      final path = studentId != null ? '/messages?studentId=$studentId' : '/messages';
      final res = await client.get(path, token: token);
      
      if (res.data == null) {
        return [];
      }
      
      final items = res.data['items'];
      if (items == null || items is! List) {
        return [];
      }
      
      final itemsList = List<Map<String, dynamic>>.from(items);
      return itemsList.map((e) {
        try {
          return Message.fromJson(e);
        } catch (e) {
          print('Erro ao parsear mensagem: $e');
          return null;
        }
      }).whereType<Message>().toList();
    } catch (e) {
      print('Erro ao listar mensagens: $e');
      return [];
    }
  }

  Future<Message> sendMessage({
    required String content,
    String? toStudentId,
    String? toStudentName,
    bool broadcast = false,
  }) async {
    final token = await authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }
    
    print('Enviando mensagem com token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    
    final payload = {
      'content': content,
      'isBroadcast': broadcast,
      if (toStudentId != null && !broadcast) 'toId': toStudentId,
    };
    
    try {
      final res = await client.post('/messages', data: payload, token: token);
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['ok'] == true && res.data['message'] != null) {
          return Message.fromJson(res.data['message']);
        } else {
          throw Exception(res.data['error'] ?? 'Erro ao enviar mensagem');
        }
      } else {
        throw Exception('Erro ${res.statusCode}: ${res.data['error'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      rethrow;
    }
  }
}

