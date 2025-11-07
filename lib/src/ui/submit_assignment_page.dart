// lib/src/ui/submit_assignment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/courses_provider.dart';
import '../models/assignment.dart';
import 'package:go_router/go_router.dart';

class SubmitAssignmentPage extends ConsumerStatefulWidget {
  final String courseId;
  final Assignment assignment;
  final String studentId;
  final String? studentName;

  const SubmitAssignmentPage({
    required this.courseId,
    required this.assignment,
    required this.studentId,
    this.studentName,
    super.key,
  });

  @override
  ConsumerState<SubmitAssignmentPage> createState() => _SubmitAssignmentPageState();
}

class _SubmitAssignmentPageState extends ConsumerState<SubmitAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  String? _selectedFileName;
  String? _selectedFilePath;
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

    setState(() => _saving = true);

    try {
      final submit = ref.read(submitAssignmentProvider);
      await submit(
        assignmentId: widget.assignment.id,
        studentId: widget.studentId,
        studentName: widget.studentName,
        fileName: _selectedFileName,
        fileUrl: _selectedFilePath, // Em produção, isso seria uma URL após upload
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade enviada com sucesso!')),
        );
        context.pop(true);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Atividade'),
        backgroundColor: const Color(0xFF1FB1C2),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informações da atividade
            Card(
              color: const Color(0xFF1FB1C2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assignment.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.assignment.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
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
                hintText: 'Adicione observações sobre sua entrega...',
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
      ),
    );
  }
}

