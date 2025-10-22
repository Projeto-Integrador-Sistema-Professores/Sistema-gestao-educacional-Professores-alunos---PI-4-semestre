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
      // Menu lateral com logo no rodapé
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 8, 174, 186),
                    ),
                    child: Text(
                      'Dashboard do Professor',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.book, color: Colors.black),
                    title: const Text('Minhas Matérias'),
                    onTap: () {
                      Navigator.pop(context); // fecha o menu
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.message, color: Colors.black),
                    title: const Text('Mensagens'),
                    onTap: () {
                      context.push('/messages');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Configurações'),
                    onTap: () {
                      context.push('/settings');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sair',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      await authSvc.logout();
                      ref.read(authStateProvider.notifier).state =
                          AuthState(isAuthenticated: false);
                      if (context.mounted) context.go('/');
                    },
                  ),
                ],
              ),
            ),

            //Logo Poliedro no rodapé centralizado
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logopoliedro.png', //Caminho da logo
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Colégio Poliedro',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // AppBar igual à tela "Mensagens"
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC66E),
        elevation: 0,
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Minhas Matérias',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Corpo da página
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: coursesAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text('Nenhuma matéria encontrada.'));
            }
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
