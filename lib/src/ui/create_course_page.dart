// lib/src/ui/create_course_page.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _uuid = const Uuid();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final newCourse = {
      'id': _uuid.v4(),
      'name': _nameCtrl.text.trim(),
      'code': _codeCtrl.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
      // adicione outros campos que desejar
    };

    // Devolve o novo objeto para a página anterior (ela irá persistir)
    Navigator.of(context).pop(newCourse);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1FB1C2), const Color(0xFFFFC66E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Torna o fundo do Scaffold transparente para mostrar o gradiente
        appBar: AppBar(
          title: const Text('Criar Matéria'),
          backgroundColor: Colors.transparent, // Torna o AppBar transparente para mostrar o gradiente atrás dele
          elevation: 0, // Remove a sombra para um visual mais limpo
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome da matéria'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Código (ex: MAT101)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o código' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}