import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';

class AllStudentsPage extends ConsumerWidget {
  const AllStudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(allStudentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Alunos')),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum aluno cadastrado.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final s = items[i];
              final subjects = (s['subjects'] as List).cast<String>();
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(s['name'] ?? ''),
                subtitle: Text('RA: ${s['ra'] ?? ''}\n${subjects.isEmpty ? 'Sem matérias' : 'Matérias: ' + subjects.join(', ')}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (ctx) => const _CreateStudentDialog(),
          );
          if (created == true) {
            // refresh list
            // ignore: unused_local_variable
            final _ = ref.refresh(allStudentsProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateStudentDialog extends ConsumerStatefulWidget {
  const _CreateStudentDialog();

  @override
  ConsumerState<_CreateStudentDialog> createState() => _CreateStudentDialogState();
}

class _CreateStudentDialogState extends ConsumerState<_CreateStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _raCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _raCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo aluno'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _raCtrl,
              decoration: const InputDecoration(labelText: 'RA'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o RA' : null,
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
                  final create = ref.read(createStudentProvider);
                  await create(_nameCtrl.text.trim(), _raCtrl.text.trim());
                  if (mounted) {
                    setState(() => _saving = false);
                    Navigator.pop(context, true);
                  }
                },
          child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
        ),
      ],
    );
  }
}


