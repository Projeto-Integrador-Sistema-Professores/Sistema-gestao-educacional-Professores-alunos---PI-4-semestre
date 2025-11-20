// lib/src/models/message.dart
class Message {
  final String id;
  final String fromId; // professor ID
  final String? toId; // aluno ID (null = todos)
  final String? toName; // nome do aluno (ou "Todos" se for broadcast)
  final String content;
  final DateTime sentAt;
  final bool isBroadcast; // true se enviado para todos

  Message({
    required this.id,
    required this.fromId,
    this.toId,
    this.toName,
    required this.content,
    required this.sentAt,
    this.isBroadcast = false,
  });

  factory Message.fromJson(Map<String, dynamic> j) {
    DateTime parsedDate;
    final date = j['sentAt'];
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      parsedDate = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(date);
    } else {
      parsedDate = DateTime.now();
    }

    return Message(
      id: j['id']?.toString() ?? '',
      fromId: j['fromId']?.toString() ?? '',
      toId: j['toId']?.toString(),
      toName: j['toName']?.toString(),
      content: j['content']?.toString() ?? '',
      sentAt: parsedDate,
      isBroadcast: j['isBroadcast'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromId': fromId,
        if (toId != null) 'toId': toId,
        if (toName != null) 'toName': toName,
        'content': content,
        'sentAt': sentAt.toIso8601String(),
        'isBroadcast': isBroadcast,
      };
}

