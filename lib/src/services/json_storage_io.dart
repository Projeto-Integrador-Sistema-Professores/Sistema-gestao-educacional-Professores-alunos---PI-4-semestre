// lib/src/services/json_storage_io.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Implementação para IO que grava arquivos no diretório de documentos.
/// Mesma API usada pela versão web, portanto o resto do app pode usar JsonStorage.instance.
class JsonStorage {
  JsonStorage._();
  static final JsonStorage instance = JsonStorage._();

  Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/gestor_alunos_data');
    if (!await folder.exists()) await folder.create(recursive: true);
    return folder;
  }

  Future<File> _courseFile(String courseId) async {
    final d = await _baseDir();
    return File('${d.path}/course_$courseId.json');
  }

  Future<Map<String, dynamic>> readCourseData(String courseId) async {
    try {
      final f = await _courseFile(courseId);
      if (!await f.exists()) {
        final init = {"assignments": [], "grades": []};
        await f.writeAsString(jsonEncode(init));
        return init;
      }
      final content = await f.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      data['assignments'] = (data['assignments'] as List<dynamic>?) ?? [];
      data['grades'] = (data['grades'] as List<dynamic>?) ?? [];
      return data;
    } catch (e) {
      return {"assignments": [], "grades": []};
    }
  }

  Future<void> writeCourseData(String courseId, Map<String, dynamic> data) async {
    final f = await _courseFile(courseId);
    await f.writeAsString(jsonEncode(data));
  }

  Future<void> appendAssignment(String courseId, Map<String, dynamic> assignment) async {
    final data = await readCourseData(courseId);
    final assignments = List<Map<String, dynamic>>.from(data['assignments'] as List<dynamic>);
    assignments.add(assignment);
    data['assignments'] = assignments;
    await writeCourseData(courseId, data);
  }

  Future<void> appendGrade(String courseId, Map<String, dynamic> grade) async {
    final data = await readCourseData(courseId);
    final grades = List<Map<String, dynamic>>.from(data['grades'] as List<dynamic>);
    grades.add(grade);
    data['grades'] = grades;
    await writeCourseData(courseId, data);
  }

  Future<void> clearCourse(String courseId) async {
    try {
      final f = await _courseFile(courseId);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
  }
}
