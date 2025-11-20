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
import '../models/subject.dart';
import '../services/subject_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const CreateCoursePage()),
    );

    if (result != null) {
      try {
        // Chama a API para criar a matéria no backend
        final create = ref.read(createCourseProvider);
        final course = await create(
          name: (result['name'] ?? '').toString(),
          code: (result['code'] ?? '').toString(),
          description: result['description']?.toString(),
        );

        // Também persiste localmente para compatibilidade (se useFakeApi estiver ativo)
        final storage = SubjectStorage();
        final subject = Subject(
          id: course.id,
          name: course.title,
          code: course.code,
        );
        await storage.addSubject(subject);

        // força atualização da lista principal
        if (mounted) {
          ref.refresh(coursesListProvider);
          context.push('/course/${course.id}');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar matéria: $e')),
          );
        }
      }
    }
  }

  Future<void> _removeLocalCourse(String id) async {
    setState(() {
      _localCourses.removeWhere((c) => c['id'] == id);
    });
    await _saveLocalCourses();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesListProvider);

    return Scaffold(
      extendBodyBehindAppBar: true, // IMPORTANTE para o degradê ficar atrás da AppBar
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text('Minhas Matérias'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1FB1C2),
                      Color(0xFFFFC66E),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'Navegação',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Ajustado para branco para contraste no gradiente
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: const Text('Matérias'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: const Text('Alunos'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/students');
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('Mensagens'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/messages');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Configuração'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuração: em breve')),
                  );
                },
              ),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('LogOut'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authStateProvider.notifier).state =
                      AuthState(isAuthenticated: false);
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1FB1C2),
              Color(0xFFFFC66E),
            ],
          ),
        ),

        child: SafeArea(
          child: coursesAsync.when(
            data: (list) {
              final total = list.length + _localCourses.length;

              if (total == 0) {
                if (_loadingLocal) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(
                    child: Text('Nenhuma matéria encontrada.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: total,
                itemBuilder: (ctx, idx) {
                  if (idx < list.length) {
                    final course = list[idx];
                    return CourseCard(
                      course: course,
                      onDelete: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Excluir matéria'),
                            content:
                                Text('Deseja excluir "${course.title}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar')),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Excluir')),
                            ],
                          ),
                        );
                        if (confirmed != true) return;

                        final delete = ref.read(deleteCourseProvider);
                        final ok = await delete(course.id);
                        if (ok) {
                          if (mounted) {
                            final _ = ref.refresh(coursesListProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Matéria excluída')),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Falha ao excluir')),
                            );
                          }
                        }
                      },
                    );
                  } else {
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
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'delete', child: Text('Remover')),
                          ],
                        ),
                        onTap: () {
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
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, s) =>
                Center(child: Text('Erro ao carregar: $e')),
          ),
        ),
      ),
      floatingActionButton: ref.watch(authStateProvider).user?.role == 'teacher'
          ? FloatingActionButton(
              onPressed: _onCreateCourse,
              tooltip: 'Criar Matéria',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}