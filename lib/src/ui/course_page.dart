import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/courses_provider.dart';
import '../providers/auth_provider.dart';
import 'widgets/material_tile.dart';
import 'widgets/assignment_tile.dart';
import 'package:go_router/go_router.dart';
import '../models/material_item.dart';
import 'download_helper.dart';

class CoursePage extends ConsumerStatefulWidget {
  final String courseId;
  const CoursePage({required this.courseId, super.key});

  @override
  ConsumerState<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends ConsumerState<CoursePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Atualiza o estado quando a aba muda
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Matéria'),
      ),
      // Botão flutuante só aparece na aba de Atividades (índice 1) e apenas para professores
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tabController.index == 1 &&
              ref.watch(authStateProvider).user?.role == 'teacher'
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF1FB1C2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                icon: const Icon(Icons.add),
                label: const Text('Nova Atividade'),
                onPressed: () {
                  context.push('/course/${widget.courseId}/create-assignment');
                },
              ),
            )
          : null,
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (data) {
            final course = data['course'];
            final materials = data['materials'] as List;
            final assignments = data['assignments'] as List;
            final grades = data['grades'] as List;

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(course.description),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Materiais'),
                            Tab(text: 'Atividades'),
                            Tab(text: 'Alunos'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Materiais
                              _MaterialsTab(
                                courseId: widget.courseId,
                                materials: materials,
                              ),

                              // Atividades
                              ListView.builder(
                                itemCount: assignments.length,
                                itemBuilder: (ctx, i) {
                                  return AssignmentTile(
                                    item: assignments[i],
                                    color: const Color(0xFF1FB1C2),
                                    courseId: widget.courseId,
                                  );
                                },
                              ),

                              // Alunos
                              _StudentsTab(
                                courseId: widget.courseId,
                                assignments: assignments,
                                grades: grades,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
      ),
    );
  }
}

class _StudentsTab extends ConsumerWidget {
  final String courseId;
  final List assignments;
  final List grades;

  const _StudentsTab({
    required this.courseId,
    required this.assignments,
    required this.grades,
  });

  double _calculateAverage(String studentId, List assignments, List grades) {
    final studentGrades = grades.where((g) {
      final gId = (g is Map) ? (g['studentId'] ?? '') : (g.studentId ?? '');
      return gId == studentId;
    }).toList();

    if (studentGrades.isEmpty || assignments.isEmpty) return 0.0;

    double totalWeight = 0.0;
    double weightedSum = 0.0;

    for (final assignment in assignments) {
      final assignmentId = (assignment is Map) ? (assignment['id'] ?? '') : (assignment.id ?? '');
      final weight = (assignment is Map) 
          ? ((assignment['weight'] ?? 0.0) as num).toDouble()
          : (assignment.weight ?? 0.0);

      final gradeOpt = studentGrades.where((g) {
        final gAssignmentId = (g is Map) ? (g['assignmentId'] ?? '') : (g.assignmentId ?? '');
        return gAssignmentId == assignmentId;
      });

      if (gradeOpt.isNotEmpty) {
        final grade = gradeOpt.first;
        final score = (grade is Map)
            ? ((grade['score'] ?? grade['finalGrade'] ?? 0.0) as num).toDouble()
            : (grade.score ?? grade.finalGrade ?? 0.0);
        if (score > 0) {
          weightedSum += score * weight;
          totalWeight += weight;
        }
      }
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsListProvider(courseId));

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar alunos: $e')),
      data: (studentsList) {
        if (studentsList.isEmpty) {
          return const Center(child: Text('Nenhum aluno cadastrado nesta matéria.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: studentsList.length,
                itemBuilder: (ctx, i) {
                  final student = studentsList[i];
                  final average = _calculateAverage(student.id, assignments, grades);
                  
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student.name),
                    subtitle: Text('RA: ${student.ra}\nMédia: ${average.toStringAsFixed(1)}'),
                    isThreeLine: true,
                    trailing: ref.watch(authStateProvider).user?.role == 'teacher'
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Lançar nota',
                            onPressed: () {
                              final firstAssignmentId =
                                  (assignments.isNotEmpty && assignments[0] is Map)
                                      ? (assignments[0]['id'] ?? '')
                                      : (assignments.isNotEmpty ? assignments[0].id ?? '' : '');
                              context.push(
                                  '/course/$courseId/grade?studentId=${student.id}&assignmentId=$firstAssignmentId');
                            },
                          )
                        : null,
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => context.push('/course/$courseId/students'),
              icon: const Icon(Icons.group),
              label: const Text('Ver lista completa de alunos'),
            ),
          ],
        );
      },
    );
  }
}

// Widget para a aba de materiais
class _MaterialsTab extends ConsumerStatefulWidget {
  final String courseId;
  final List materials;

  const _MaterialsTab({
    required this.courseId,
    required this.materials,
  });

  @override
  ConsumerState<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends ConsumerState<_MaterialsTab> {
  Future<void> _downloadMaterial(MaterialItem material) async {
    try {
      // Usa o fileStorageId se disponível, senão tenta extrair do fileUrl
      final fileStorageId = material.fileStorageId ?? 
          (material.fileUrl.contains('/materials/') 
              ? material.fileUrl.split('/materials/')[1].split('/download')[0]
              : null);
      
      if (fileStorageId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ID do arquivo não encontrado')),
          );
        }
        return;
      }

      final download = ref.read(downloadMaterialProvider);
      final data = await download(fileStorageId, fileName: material.fileName);
      
      if (data.isEmpty || data['fileData'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arquivo não encontrado')),
          );
        }
        return;
      }

      final fileData = data['fileData'] as String;
      final fileName = data['fileName'] ?? material.fileName ?? material.title;

      if (kIsWeb) {
        // Na web, usa helper para download
        downloadFileWeb(fileData, fileName);
      } else {
        // Em mobile/desktop, salva o arquivo
        await downloadFileIO(data['bytes'] as List<int>, fileName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download concluído: $fileName')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao baixar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.materials.isEmpty
              ? const Center(child: Text('Nenhum material disponível.'))
              : ListView.builder(
                  itemCount: widget.materials.length,
                  itemBuilder: (ctx, i) {
                    final material = widget.materials[i] is MaterialItem
                        ? widget.materials[i] as MaterialItem
                        : MaterialItem.fromJson(Map<String, dynamic>.from(widget.materials[i]));
                    return MaterialTile(
                      item: material,
                      color: const Color(0xFF1FB1C2),
                      onDownload: () => _downloadMaterial(material),
                    );
                  },
                ),
        ),
        if (ref.watch(authStateProvider).user?.role == 'teacher')
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final added = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => _AddMaterialDialog(courseId: widget.courseId),
                  );
                  if (added == true) {
                    // Atualiza a lista
                    final _ = ref.refresh(courseDetailProvider(widget.courseId));
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1FB1C2),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddMaterialDialog extends ConsumerStatefulWidget {
  final String courseId;

  const _AddMaterialDialog({required this.courseId});

  @override
  ConsumerState<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends ConsumerState<_AddMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String? _selectedFileName;
  String? _selectedFileData;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png', 'ppt', 'pptx'],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        final file = result.files.single;
        setState(() {
          _selectedFileName = file.name;
          
          if (kIsWeb) {
            if (file.bytes != null) {
              _selectedFileData = base64Encode(file.bytes!);
            } else {
              _selectedFileName = null;
              _selectedFileData = null;
            }
          } else {
            // Em mobile/desktop, salvaria o arquivo e usaria o path
            _selectedFileData = file.path;
          }
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um arquivo')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final create = ref.read(createMaterialProvider);
      await create(
        courseId: widget.courseId,
        title: _titleCtrl.text.trim(),
        fileName: _selectedFileName!,
        fileData: _selectedFileData,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material adicionado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar: $e')),
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
    return AlertDialog(
      title: const Text('Adicionar Material'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título do Material',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
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
                      _selectedFileData = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Adicionar'),
        ),
      ],
    );
  }
}