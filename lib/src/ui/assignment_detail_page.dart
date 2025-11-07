// lib/src/ui/assignment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/courses_provider.dart';
import '../models/assignment.dart';
import '../models/submission.dart';

class AssignmentDetailPage extends ConsumerWidget {
  final String courseId;
  final Assignment assignment;

  const AssignmentDetailPage({
    required this.courseId,
    required this.assignment,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionsProvider(assignment.id));
    final studentsAsync = ref.watch(studentsListProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
        backgroundColor: const Color(0xFFFFC66E),
      ),
      body: Column(
        children: [
          // Informações da atividade
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1FB1C2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Prazo: ${DateFormat('dd/MM/yyyy').format(assignment.dueDate)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.scale, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Peso: ${assignment.weight.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lista de alunos e status de entrega
          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Erro ao carregar alunos: $e')),
              data: (students) {
                return submissionsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erro ao carregar entregas: $e')),
                  data: (submissions) {
                    // Cria mapa de submissions por studentId
                    final submissionMap = {
                      for (var s in submissions) s.studentId: s
                    };

                    // Separa alunos que entregaram e que não entregaram
                    final submitted = <Map<String, dynamic>>[];
                    final notSubmitted = <Map<String, dynamic>>[];

                    for (final student in students) {
                      final submission = submissionMap[student.id];
                      if (submission != null) {
                        submitted.add({
                          'student': student,
                          'submission': submission,
                        });
                      } else {
                        notSubmitted.add({
                          'student': student,
                        });
                      }
                    }

                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        if (submitted.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Entregas Realizadas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          ...submitted.map((item) {
                            final student = item['student'];
                            final submission = item['submission'] as Submission;
                            return Card(
                              color: Colors.green[50],
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.check, color: Colors.white),
                                ),
                                title: Text(student.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('RA: ${student.ra}'),
                                    if (submission.fileName != null)
                                      Text('Arquivo: ${submission.fileName}'),
                                    Text(
                                      'Enviado em: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    if (submission.notes != null && submission.notes!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Observações: ${submission.notes}',
                                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                        if (notSubmitted.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Pendentes de Entrega',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          ...notSubmitted.map((item) {
                            final student = item['student'];
                            return Card(
                              color: Colors.orange[50],
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Icon(Icons.pending, color: Colors.white),
                                ),
                                title: Text(student.name),
                                subtitle: Text('RA: ${student.ra}'),
                              ),
                            );
                          }),
                        ],
                        if (submitted.isEmpty && notSubmitted.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('Nenhum aluno cadastrado nesta matéria.'),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

