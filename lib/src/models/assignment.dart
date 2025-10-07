// lib/src/models/assignment.dart
class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final double weight;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.weight,
  });

  /// Cria um Assignment a partir de um JSON dinâmico.
  /// Tolerante a:
  /// - j['dueDate'] sendo String (ISO), DateTime, int (msSinceEpoch)
  /// - j pode conter nulls
  factory Assignment.fromJson(Map<String, dynamic> j) {
    DateTime parsedDue;

    final dd = j['dueDate'];
    if (dd == null) {
      parsedDue = DateTime.now();
    } else if (dd is DateTime) {
      parsedDue = dd;
    } else if (dd is int) {
      // epoch milliseconds
      parsedDue = DateTime.fromMillisecondsSinceEpoch(dd);
    } else if (dd is String) {
      // tenta parse ISO ou timestamp em string
      final maybe = DateTime.tryParse(dd);
      if (maybe != null) {
        parsedDue = maybe;
      } else {
        // tentar interpretar como número em string
        final asNum = int.tryParse(dd);
        if (asNum != null) {
          parsedDue = DateTime.fromMillisecondsSinceEpoch(asNum);
        } else {
          parsedDue = DateTime.now();
        }
      }
    } else {
      // fallback seguro
      parsedDue = DateTime.now();
    }

    return Assignment(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      dueDate: parsedDue,
      weight: (j['weight'] is num) ? (j['weight'] as num).toDouble() : double.tryParse('${j['weight'] ?? 1.0}') ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        // padronizamos a saída como string ISO — importante para persistência JSON
        'dueDate': dueDate.toIso8601String(),
        'weight': weight,
      };
}
