// lib/src/ui/assignment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/courses_provider.dart';
import '../models/assignment.dart';
import '../models/submission.dart';
import '../models/user.dart';

class AssignmentDetailPage extends ConsumerWidget {
  final String courseId;
  final Assignment assignment;

  const AssignmentDetailPage({
    required this.courseId,
    required this.assignment,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
        backgroundColor: const Color(0xFFFFC66E),
      ),
      body: Column(
        children: [
          // Informações da atividade
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1FB1C2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Prazo: ${DateFormat('dd/MM/yyyy').format(assignment.dueDate)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.scale, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Peso: ${assignment.weight.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Abas: Entregas e Enviar Entrega
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Entregas'),
                      Tab(text: 'Enviar Entrega'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Aba 1: Lista de entregas
                        _SubmissionsListTab(
                          courseId: courseId,
                          assignment: assignment,
                        ),
                        // Aba 2: Formulário de envio
                        _SubmitFormTab(
                          courseId: courseId,
                          assignment: assignment,
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
  }
}

// Widget para a aba de lista de entregas
class _SubmissionsListTab extends ConsumerWidget {
  final String courseId;
  final Assignment assignment;

  const _SubmissionsListTab({
    required this.courseId,
    required this.assignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionsProvider(assignment.id));
    final studentsAsync = ref.watch(studentsListProvider(courseId));

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar alunos: $e')),
      data: (students) {
        return submissionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erro ao carregar entregas: $e')),
          data: (submissions) {
            // Cria mapa de submissions por studentId
            final submissionMap = {
              for (var s in submissions) s.studentId: s
            };

            // Separa alunos que entregaram e que não entregaram
            final submitted = <Map<String, dynamic>>[];
            final notSubmitted = <Map<String, dynamic>>[];

            for (final student in students) {
              final submission = submissionMap[student.id];
              if (submission != null) {
                submitted.add({
                  'student': student,
                  'submission': submission,
                });
              } else {
                notSubmitted.add({
                  'student': student,
                });
              }
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (submitted.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Entregas Realizadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ...submitted.map((item) {
                    final student = item['student'] as User;
                    final submission = item['submission'] as Submission;
                    return Card(
                      color: Colors.green[50],
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text(student.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RA: ${student.ra}'),
                            if (submission.fileName != null)
                              Text('Arquivo: ${submission.fileName}'),
                            Text(
                              'Enviado em: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (submission.notes != null && submission.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Observações: ${submission.notes}',
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                if (notSubmitted.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Pendentes de Entrega',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  ...notSubmitted.map((item) {
                    final student = item['student'] as User;
                    return Card(
                      color: Colors.orange[50],
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.pending, color: Colors.white),
                        ),
                        title: Text(student.name),
                        subtitle: Text('RA: ${student.ra}'),
                      ),
                    );
                  }),
                ],
                if (submitted.isEmpty && notSubmitted.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Nenhum aluno cadastrado nesta matéria.'),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

// Widget para a aba de formulário de envio
class _SubmitFormTab extends ConsumerStatefulWidget {
  final String courseId;
  final Assignment assignment;

  const _SubmitFormTab({
    required this.courseId,
    required this.assignment,
  });

  @override
  ConsumerState<_SubmitFormTab> createState() => _SubmitFormTabState();
}

class _SubmitFormTabState extends ConsumerState<_SubmitFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  String? _selectedFileName;
  String? _selectedFilePath;
  String? _selectedStudentId;
  String? _selectedStudentName;
  bool _saving = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _selectedFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um arquivo para enviar')),
      );
      return;
    }
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um aluno')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final submit = ref.read(submitAssignmentProvider);
      await submit(
        assignmentId: widget.assignment.id,
        studentId: _selectedStudentId!,
        studentName: _selectedStudentName,
        fileName: _selectedFileName,
        fileUrl: _selectedFilePath,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade enviada com sucesso!')),
        );
        // Limpa o formulário
        setState(() {
          _selectedFileName = null;
          _selectedFilePath = null;
          _selectedStudentId = null;
          _selectedStudentName = null;
          _notesCtrl.clear();
        });
        // Atualiza a lista de entregas
        final _ = ref.refresh(submissionsProvider(widget.assignment.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsListProvider(widget.courseId));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seleção de aluno
          const Text(
            'Selecionar Aluno',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          studentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Erro: $e'),
            data: (students) {
              if (students.isEmpty) {
                return const Text('Nenhum aluno cadastrado nesta matéria.');
              }
              return DropdownButtonFormField<String>(
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Aluno',
                  border: OutlineInputBorder(),
                ),
                items: students.map((student) {
                  return DropdownMenuItem<String>(
                    value: student.id,
                    child: Text('${student.name} (RA: ${student.ra})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStudentId = value;
                    final student = students.firstWhere((s) => s.id == value);
                    _selectedStudentName = student.name;
                  });
                },
                validator: (v) => v == null ? 'Selecione um aluno' : null,
              );
            },
          ),
          const SizedBox(height: 24),
          // Seleção de arquivo
          const Text(
            'Arquivo da Atividade',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _saving ? null : _pickFile,
            icon: const Icon(Icons.attach_file),
            label: Text(_selectedFileName ?? 'Selecionar Arquivo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1FB1C2),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          if (_selectedFileName != null) ...[
            const SizedBox(height: 8),
            Chip(
              label: Text(_selectedFileName!),
              onDeleted: () {
                setState(() {
                  _selectedFileName = null;
                  _selectedFilePath = null;
                });
              },
            ),
          ],
          const SizedBox(height: 24),
          // Observações
          const Text(
            'Observações (opcional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              hintText: 'Adicione observações sobre a entrega...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          // Botão de enviar
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enviar Atividade'),
          ),
        ],
      ),
    );
  }
}

