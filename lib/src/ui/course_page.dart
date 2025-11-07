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
              final _ = ref.refresh(courseDetailProvider(courseId));
              final __ = ref.refresh(studentsListProvider(courseId));
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
                                  courseId: courseId,
                                ),
                              ),

                              // Alunos
                              _StudentsTab(
                                courseId: courseId,
                                assignments: assignments,
                                grades: grades,
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

class _StudentsTab extends ConsumerWidget {
  final String courseId;
  final List assignments;
  final List grades;

  const _StudentsTab({
    required this.courseId,
    required this.assignments,
    required this.grades,
  });

  double _calculateAverage(String studentId, List assignments, List grades) {
    final studentGrades = grades.where((g) {
      final gId = (g is Map) ? (g['studentId'] ?? '') : (g.studentId ?? '');
      return gId == studentId;
    }).toList();

    if (studentGrades.isEmpty || assignments.isEmpty) return 0.0;

    double totalWeight = 0.0;
    double weightedSum = 0.0;

    for (final assignment in assignments) {
      final assignmentId = (assignment is Map) ? (assignment['id'] ?? '') : (assignment.id ?? '');
      final weight = (assignment is Map) 
          ? ((assignment['weight'] ?? 0.0) as num).toDouble()
          : (assignment.weight ?? 0.0);

      final gradeOpt = studentGrades.where((g) {
        final gAssignmentId = (g is Map) ? (g['assignmentId'] ?? '') : (g.assignmentId ?? '');
        return gAssignmentId == assignmentId;
      });

      if (gradeOpt.isNotEmpty) {
        final grade = gradeOpt.first;
        final score = (grade is Map)
            ? ((grade['score'] ?? grade['finalGrade'] ?? 0.0) as num).toDouble()
            : (grade.score ?? grade.finalGrade ?? 0.0);
        if (score > 0) {
          weightedSum += score * weight;
          totalWeight += weight;
        }
      }
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsListProvider(courseId));

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar alunos: $e')),
      data: (studentsList) {
        if (studentsList.isEmpty) {
          return const Center(child: Text('Nenhum aluno cadastrado nesta matéria.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: studentsList.length,
                itemBuilder: (ctx, i) {
                  final student = studentsList[i];
                  final average = _calculateAverage(student.id, assignments, grades);
                  
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student.name),
                    subtitle: Text('RA: ${student.ra}\nMédia: ${average.toStringAsFixed(1)}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Lançar nota',
                      onPressed: () {
                        final firstAssignmentId =
                            (assignments.isNotEmpty && assignments[0] is Map)
                                ? (assignments[0]['id'] ?? '')
                                : (assignments.isNotEmpty ? assignments[0].id ?? '' : '');
                        context.push(
                            '/course/$courseId/grade?studentId=${student.id}&assignmentId=$firstAssignmentId');
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
        );
      },
    );
  }
}
