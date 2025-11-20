import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/assignment.dart';

class AssignmentTile extends StatelessWidget {
  final dynamic item;
  final String? courseId;
  final Color? color; // ← nova cor opcional

  const AssignmentTile({
    required this.item,
    this.courseId,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Assignment assignment;

    if (item is Assignment) {
      assignment = item;
    } else if (item is Map<String, dynamic>) {
      assignment = Assignment.fromJson(Map<String, dynamic>.from(item));
    } else {
      try {
        assignment = Assignment.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      } catch (_) {
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),

          // ⭐ Agora a cor VEM DO PARÂMETRO "color"
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color ?? const Color(0xFF1FB1C2), // fallback caso não envie cor
              const Color(0xFFFFC66E),
            ],
          ),
        ),
        child: ListTile(
          leading: const Icon(Icons.task_alt, color: Colors.white),
          title: Text(
            assignment.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            assignment.description,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(due),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Peso: ${assignment.weight.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          // 🔗 Navegar ao clicar
          onTap: courseId != null
              ? () {
                  final uri = Uri(
                    path: '/course/$courseId/assignment/${assignment.id}',
                    queryParameters: {
                      'title': assignment.title,
                      'description': assignment.description,
                      'dueDate': assignment.dueDate.toIso8601String(),
                      'weight': assignment.weight.toString(),
                    },
                  );
                  context.push(uri.toString());
                }
              : null,
        ),
      ),
    );
  }
}
