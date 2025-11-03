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
              final subjectIds = (s['subjectIds'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(s['name'] ?? ''),
                subtitle: Text('RA: ${s['ra'] ?? ''}\n${subjects.isEmpty ? 'Sem matérias' : 'Matérias: ' + subjects.join(', ')}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar matérias',
                  onPressed: () async {
                    final updated = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => _EditEnrollmentsDialog(
                        studentId: (s['id'] ?? '').toString(),
                        initialSubjectIds: subjectIds,
                      ),
                    );
                    if (updated == true) {
                      // ignore: unused_local_variable
                      final _ = ref.refresh(allStudentsProvider);
                    }
                  },
                ),
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

class _EditEnrollmentsDialog extends ConsumerStatefulWidget {
  final String studentId;
  final List<String> initialSubjectIds;
  const _EditEnrollmentsDialog({required this.studentId, required this.initialSubjectIds});

  @override
  ConsumerState<_EditEnrollmentsDialog> createState() => _EditEnrollmentsDialogState();
}

class _EditEnrollmentsDialogState extends ConsumerState<_EditEnrollmentsDialog> {
  late List<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.initialSubjectIds);
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesListProvider);
    return AlertDialog(
      title: const Text('Editar matérias'),
      content: SizedBox(
        width: 420,
        child: coursesAsync.when(
          loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
          error: (e, s) => Text('Erro: $e'),
          data: (courses) {
            return SizedBox(
              height: 320,
              width: 420,
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (ctx, i) {
                  final c = courses[i];
                  final checked = _selected.contains(c.id);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(c.title),
                    subtitle: Text(c.code),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          if (!_selected.contains(c.id)) _selected.add(c.id);
                        } else {
                          _selected.remove(c.id);
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
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
                  setState(() => _saving = true);
                  final update = ref.read(updateStudentEnrollmentsProvider);
                  final ok = await update(widget.studentId, _selected);
                  if (mounted) {
                    setState(() => _saving = false);
                    Navigator.pop(context, ok == true);
                  }
                },
          child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
        ),
      ],
    );
  }
}


