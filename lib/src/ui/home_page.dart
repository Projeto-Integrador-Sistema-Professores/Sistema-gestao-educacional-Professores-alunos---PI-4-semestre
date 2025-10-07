import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';
import '../ui/widgets/course_card.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesListProvider);
    final authSvc = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Matérias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authSvc.logout();
              ref.read(authStateProvider.notifier).state = AuthState(isAuthenticated: false);
              if (context.mounted) context.go('/');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: coursesAsync.when(
          data: (list) {
            if (list.isEmpty) return const Center(child: Text('Nenhuma matéria encontrada.'));
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, idx) => CourseCard(course: list[idx]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erro ao carregar: $e')),
        ),
      ),
    );
  }
}
