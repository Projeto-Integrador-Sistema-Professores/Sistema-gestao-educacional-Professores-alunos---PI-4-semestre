import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';
import 'widgets/material_tile.dart';
import 'widgets/assignment_tile.dart';
import 'package:go_router/go_router.dart';

class CoursePage extends ConsumerWidget {
  final String courseId;
  const CoursePage({required this.courseId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matéria'),
        backgroundColor: const Color(0xFFFFC66E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(courseDetailProvider(courseId));
            },
          ),
        ],
      ),

      // Botão flutuante
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1FB1C2),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Nova Atividade'),
        onPressed: () {
          context.push('/course/$courseId/create-assignment');
        },
      ),

      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (data) {
          final course = data['course'];
          final materials = data['materials'] as List;
          final assignments = data['assignments'] as List;
          final grades = data['grades'] as List;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(course.description),
                const SizedBox(height: 12),

                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Materiais'),
                            Tab(text: 'Atividades'),
                            Tab(text: 'Alunos'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Materiais
                              ListView.builder(
                                itemCount: materials.length,
                                itemBuilder: (ctx, i) => MaterialTile(
                                  item: materials[i],
                                  color: const Color(0xFF1FB1C2), // aplica cor
                                ),
                              ),

                              // Atividades
                              ListView.builder(
                                itemCount: assignments.length,
                                itemBuilder: (ctx, i) => AssignmentTile(
                                  item: assignments[i],
                                  color: const Color(0xFF1FB1C2), // aplica cor
                                ),
                              ),

                              // Alunos
                              Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: grades.length,
                                      itemBuilder: (ctx, i) {
                                        final g = grades[i] is Map
                                            ? Map<String, dynamic>.from(grades[i])
                                            : grades[i];
                                        final studentName = (g is Map)
                                            ? (g['studentName'] ?? g['studentId'])
                                            : (g.studentName ?? g.studentId);
                                        final finalGrade = (g is Map)
                                            ? (g['finalGrade'] ?? g['score'] ?? '-')
                                            : (g.finalGrade ?? g.score ?? '-');
                                        final studentId = (g is Map)
                                            ? (g['studentId'] ?? '')
                                            : (g.studentId ?? '');

                                        return ListTile(
                                          title: Text('$studentName'),
                                          subtitle: Text('Média: $finalGrade'),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              final firstAssignmentId =
                                                  (assignments.isNotEmpty && assignments[0] is Map)
                                                      ? (assignments[0]['id'] ?? '')
                                                      : '';
                                              context.push(
                                                  '/course/$courseId/grade?studentId=$studentId&assignmentId=$firstAssignmentId');
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => context.push('/course/$courseId/students'),
                                    icon: const Icon(Icons.group),
                                    label: const Text('Ver lista completa de alunos'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension on Alignment {
  get id => null;
}
