// lib/src/ui/create_subject_page.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../services/subject_storage.dart';

class CreateSubjectPage extends StatefulWidget {
  const CreateSubjectPage({Key? key}) : super(key: key);

  @override
  State<CreateSubjectPage> createState() => _CreateSubjectPageState();
}

class _CreateSubjectPageState extends State<CreateSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _storage = SubjectStorage();
  final _uuid = Uuid();

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

    final subject = Subject(
      id: _uuid.v4(),
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
    );

    await _storage.addSubject(subject);

    setState(() => _saving = false);
    // Fecha a página e devolve true indicando que algo mudou
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Matéria')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
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
                  child: _saving ? const CircularProgressIndicator() : const Text('Salvar'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
