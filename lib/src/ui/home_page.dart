// lib/src/ui/home_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/courses_provider.dart';
import '../ui/widgets/course_card.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'create_course_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<Map<String, dynamic>> _localCourses = [];
  bool _loadingLocal = true;

  static const String _localKey = 'custom_courses';

  @override
  void initState() {
    super.initState();
    _loadLocalCourses();
  }

  Future<void> _loadLocalCourses() async {
    setState(() => _loadingLocal = true);
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_localKey);
    if (s == null || s.isEmpty) {
      _localCourses = [];
    } else {
      try {
        final decoded = json.decode(s) as List<dynamic>;
        _localCourses = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (e) {
        _localCourses = [];
      }
    }
    setState(() => _loadingLocal = false);
  }

  Future<void> _saveLocalCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, json.encode(_localCourses));
  }

  Future<void> _onCreateCourse() async {
    // Abre a página de criação; ela retornará um Map<String,dynamic> com a nova matéria
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const CreateCoursePage()),
    );

    if (result != null) {
      // garante que o objeto tenha um id (caso CreateCoursePage não tenha gerado)
      final id = (result['id'] != null && result['id'].toString().isNotEmpty)
          ? result['id'].toString()
          : UniqueKey().toString();
      result['id'] = id;

      // adiciona à lista local e persiste
      setState(() {
        _localCourses.add(result);
      });
      await _saveLocalCourses();

      // navega para a página da matéria recém-criada
      if (mounted) {
        // usa GoRouter para navegar para a rota /course/:id
        context.push('/course/$id');
      }
    }
  }

  // Função opcional para remover matéria local (útil para testes)
  Future<void> _removeLocalCourse(String id) async {
    setState(() {
      _localCourses.removeWhere((c) => c['id'] == id);
    });
    await _saveLocalCourses();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesListProvider);
    final authSvc = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Matérias'),
      ),
      body: coursesAsync.when(
        data: (list) {
          // list -> matérias vindas do provider (provavelmente um List<Course>).
          // Vamos renderizar uma ListView combinando provider + local.
          final total = list.length + _localCourses.length;
          if (total == 0) {
            // Se ainda carregando locais, mostra loading; caso contrário, mostra texto
            if (_loadingLocal) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('Nenhuma matéria encontrada.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: total,
            itemBuilder: (ctx, idx) {
              if (idx < list.length) {
                // matéria vinda do provider -> usa CourseCard (comportamento anterior)
                final course = list[idx];
                return CourseCard(course: course);
              } else {
                // matérias locais -> mostramos com um Card simples
                final localIdx = idx - list.length;
                final c = _localCourses[localIdx];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(c['name'] ?? 'Sem nome'),
                    subtitle: Text(c['code'] ?? ''),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'delete') {
                          _removeLocalCourse(c['id'] ?? '');
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'delete', child: Text('Remover')),
                      ],
                    ),
                    onTap: () {
                      // abrir detalhes usando GoRouter
                      final id = c['id'] ?? '';
                      if (id.toString().isNotEmpty) {
                        context.push('/course/$id');
                      }
                    },
                  ),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro ao carregar: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateCourse,
        tooltip: 'Criar Matéria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
