// lib/src/ui/create_assignment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';
import 'package:go_router/go_router.dart';

class CreateAssignmentPage extends ConsumerStatefulWidget {
  final String courseId;
  const CreateAssignmentPage({required this.courseId, super.key});

  @override
  ConsumerState<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends ConsumerState<CreateAssignmentPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _dueDate;
  double _weight = 1.0;
  bool loading = false;
  String? msg;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() { _dueDate = picked; });
  }

  @override
  Widget build(BuildContext context) {
    final createAssignment = ref.read(createAssignmentProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Atividade')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 8),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Descrição'), maxLines: 3),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: Text(_dueDate == null ? 'Data de entrega não definida' : 'Entrega: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
            ),
            TextButton(onPressed: _pickDate, child: const Text('Escolher data'))
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Peso:'),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                min: 0.1,
                max: 5.0,
                divisions: 49,
                value: _weight,
                label: _weight.toStringAsFixed(1),
                onChanged: (v) => setState(() => _weight = v),
              ),
            )
          ]),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loading ? null : () async {
              if (_titleCtrl.text.trim().isEmpty || _dueDate == null) {
                setState(() { msg = 'Título e data de entrega são obrigatórios.'; });
                return;
              }
              setState(() { loading = true; msg = null; });
              try {
                final newAss = await createAssignment(widget.courseId, _titleCtrl.text.trim(), _descCtrl.text.trim(), _dueDate!, _weight);
                setState(() { msg = 'Atividade criada: ${newAss.title}'; });
                await Future.delayed(const Duration(milliseconds: 600));
                if (context.mounted) context.pop();
              } catch (e) {
                setState(() { msg = 'Erro ao criar atividade: $e'; });
              } finally {
                setState(() { loading = false; });
              }
            },
            child: loading ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Criar Atividade'),
          ),
          if (msg != null) ...[
            const SizedBox(height: 12),
            Text(msg!, style: const TextStyle(color: Colors.green)),
          ]
        ]),
      ),
    );
  }
}
