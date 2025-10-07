// lib/src/ui/grade_launch_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';
import 'package:go_router/go_router.dart';

class GradeLaunchPage extends ConsumerStatefulWidget {
  final String courseId;
  final String studentId;
  final String assignmentId;
  const GradeLaunchPage({required this.courseId, required this.studentId, required this.assignmentId, super.key});

  @override
  ConsumerState<GradeLaunchPage> createState() => _GradeLaunchPageState();
}

class _GradeLaunchPageState extends ConsumerState<GradeLaunchPage> {
  final _scoreCtrl = TextEditingController();
  bool loading = false;
  String? msg;

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitGrade = ref.read(submitGradeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lançar Nota')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text('Aluno ID: ${widget.studentId}'),
          const SizedBox(height: 12),
          TextField(
            controller: _scoreCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Nota (0.0 - 10.0)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : () async {
              final val = double.tryParse(_scoreCtrl.text.replaceAll(',', '.'));
              if (val == null || val < 0 || val > 10) {
                setState(() { msg = 'Insira uma nota válida entre 0 e 10.'; });
                return;
              }
              setState(() { loading = true; msg = null; });
              try {
                await submitGrade(widget.courseId, widget.studentId, widget.assignmentId.isEmpty ? 'a1' : widget.assignmentId, val);
                setState(() { msg = 'Nota lançada com sucesso!'; });
                // optional: go back
                await Future.delayed(const Duration(milliseconds: 600));
                if (context.mounted) context.pop();
              } catch (e) {
                setState(() { msg = 'Erro ao lançar nota: $e'; });
              } finally {
                setState(() { loading = false; });
              }
            },
            child: loading ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Lançar'),
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
