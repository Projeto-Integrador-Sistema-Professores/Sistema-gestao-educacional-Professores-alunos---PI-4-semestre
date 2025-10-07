// lib/src/ui/students_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';
import '../models/user.dart';
import 'package:go_router/go_router.dart';

class StudentsPage extends ConsumerWidget {
  final String courseId;
  const StudentsPage({required this.courseId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsListProvider(courseId));
    return Scaffold(
      appBar: AppBar(title: const Text('Alunos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: studentsAsync.when(
          data: (list) {
            if (list.isEmpty) return const Center(child: Text('Nenhum aluno matriculado.'));
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final User s = list[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(s.name),
                  subtitle: Text('RA: ${s.ra}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Lançar nota',
                    onPressed: () {
                      // navigate to grade page with query params
                      context.push('/course/$courseId/grade?studentId=${s.id}');
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e,s) => Center(child: Text('Erro ao carregar: $e')),
        ),
      ),
    );
  }
}
