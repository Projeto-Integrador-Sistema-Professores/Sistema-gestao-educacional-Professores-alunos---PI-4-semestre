// lib/src/ui/widgets/assignment_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/assignment.dart';

class AssignmentTile extends StatelessWidget {
  final dynamic item;
  const AssignmentTile({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    // Normalizar item para Assignment (se veio como Map)
    Assignment assignment;
    if (item is Assignment) {
      assignment = item as Assignment;
    } else if (item is Map<String, dynamic>) {
      assignment = Assignment.fromJson(Map<String, dynamic>.from(item));
    } else {
      // último recurso: tentar converter via Map (caso JSON decodificado com dynamic)
      try {
        final m = Map<String, dynamic>.from(item as Map);
        assignment = Assignment.fromJson(m);
      } catch (_) {
        // fallback mínimo
        assignment = Assignment(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          title: item?.toString() ?? 'Atividade',
          description: '',
          dueDate: DateTime.now(),
          weight: 1.0,
        );
      }
    }

    final due = assignment.dueDate;
    return ListTile(
      leading: const Icon(Icons.task_alt),
      title: Text(assignment.title),
      subtitle: Text(assignment.description),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('dd/MM/yyyy').format(due)),
          const SizedBox(height: 4),
          Text('Peso: ${assignment.weight.toStringAsFixed(1)}'),
        ],
      ),
    );
  }
}
