// lib/src/ui/messages_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../models/message.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(allStudentsProvider);
    final allMessagesAsync = ref.watch(messagesProvider(null));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mensagens'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
              onPressed: () {
                final _ = ref.refresh(messagesProvider(null));
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Alunos'),
              Tab(text: 'Mensagens Enviadas'),
            ],
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
                    color: Colors.white,
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
        body: TabBarView(
          children: [
            // Aba de alunos com botão no rodapé
            _StudentsTabWithButton(
              studentsAsync: studentsAsync,
            ),
            // Aba de mensagens enviadas
            allMessagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Erro: $e')),
              data: (messages) {
                // Filtra apenas mensagens do professor logado (garantia adicional)
                final currentUser = ref.watch(authStateProvider).user;
                final filteredMessages = currentUser != null
                    ? messages.where((m) => m.fromId == currentUser.id).toList()
                    : messages;
                
                if (filteredMessages.isEmpty) {
                  return const Center(child: Text('Nenhuma mensagem enviada.'));
                }
                final sorted = List<Message>.from(filteredMessages)
                  ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sorted.length,
                  itemBuilder: (ctx, i) {
                    final msg = sorted[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: msg.isBroadcast
                              ? Colors.orange
                              : const Color(0xFF1FB1C2),
                          child: Icon(
                            msg.isBroadcast
                                ? Icons.broadcast_on_personal
                                : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          msg.isBroadcast
                              ? 'Todos os Alunos'
                              : (msg.toName ?? 'Aluno'),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(msg.content),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(msg.sentAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirmar exclusão'),
                                content: const Text('Deseja realmente excluir esta mensagem?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              try {
                                final delete = ref.read(deleteMessageProvider);
                                await delete(msg.id);
                                
                                if (ctx.mounted) {
                                  // Atualiza a lista de mensagens
                                  final _ = ref.refresh(messagesProvider(null));
                                  
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mensagem excluída com sucesso!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao excluir mensagem: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) return 'Agora';
        return '${difference.inMinutes} min atrás';
      }
      return '${difference.inHours} h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Widget para a aba de alunos com botão no rodapé
class _StudentsTabWithButton extends ConsumerWidget {
  final AsyncValue<List<Map<String, dynamic>>> studentsAsync;

  const _StudentsTabWithButton({
    required this.studentsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTeacher = ref.watch(authStateProvider).user?.role == 'teacher';

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro: $e')),
      data: (students) {
        if (students.isEmpty) {
          return Column(
            children: [
              const Expanded(
                child: Center(child: Text('Nenhum aluno cadastrado.')),
              ),
              if (isTeacher)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final sent = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => _SendMessageDialog(
                          broadcast: true,
                        ),
                      );
                      if (sent == true) {
                        final _ = ref.refresh(messagesProvider(null));
                      }
                    },
                    icon: const Icon(Icons.broadcast_on_personal, size: 20),
                    label: const Text('Enviar para Todos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1FB1C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: students.length,
                itemBuilder: (ctx, i) {
                  final student = students[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student['name'] ?? ''),
                    subtitle: Text('RA: ${student['ra'] ?? ''}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final sent = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => _SendMessageDialog(
                          studentId: student['id']?.toString(),
                          studentName: student['name']?.toString(),
                          broadcast: false,
                        ),
                      );
                      if (sent == true) {
                        final _ = ref.refresh(messagesProvider(null));
                      }
                    },
                  );
                },
              ),
            ),
            // Botão no rodapé - apenas para professores
            if (isTeacher)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final sent = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => _SendMessageDialog(
                        broadcast: true,
                      ),
                    );
                    if (sent == true) {
                      final _ = ref.refresh(messagesProvider(null));
                    }
                  },
                  icon: const Icon(Icons.broadcast_on_personal, size: 20),
                  label: const Text('Enviar para Todos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FB1C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SendMessageDialog extends ConsumerStatefulWidget {
  final String? studentId;
  final String? studentName;
  final bool broadcast;

  const _SendMessageDialog({
    this.studentId,
    this.studentName,
    required this.broadcast,
  });

  @override
  ConsumerState<_SendMessageDialog> createState() => _SendMessageDialogState();
}

class _SendMessageDialogState extends ConsumerState<_SendMessageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.broadcast ? 'Enviar para Todos' : 'Enviar Mensagem'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.broadcast && widget.studentName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Para: ${widget.studentName}'),
              ),
            TextFormField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                hintText: 'Digite sua mensagem...',
              ),
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Digite a mensagem' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _saving = true);
                  
                  try {
                    final send = ref.read(sendMessageProvider);
                    await send(
                      content: _contentCtrl.text.trim(),
                      toStudentId: widget.studentId,
                      toStudentName: widget.studentName,
                      broadcast: widget.broadcast,
                    );
                    if (mounted) {
                      setState(() => _saving = false);
                      Navigator.pop(context, true);
                      
                      // Atualiza a lista de mensagens após enviar
                      final _ = ref.refresh(messagesProvider(null));
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.broadcast 
                              ? 'Mensagem enviada para todos os alunos!' 
                              : 'Mensagem enviada!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => _saving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao enviar mensagem: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}
