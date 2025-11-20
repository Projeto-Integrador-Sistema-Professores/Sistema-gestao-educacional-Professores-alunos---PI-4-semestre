// lib/src/services/json_storage_web.dart
// NOTE: este arquivo só será usado quando compilado para web.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

/// Implementação para Web usando window.localStorage.
/// Mantém a mesma API do JsonStorage IO para compatibilidade.
class JsonStorage {
  JsonStorage._();
  static final JsonStorage instance = JsonStorage._();

  String _keyForCourse(String courseId) => 'gestor_alunos_course_$courseId';

  Future<Map<String, dynamic>> readCourseData(String courseId) async {
    try {
      final key = _keyForCourse(courseId);
      final raw = html.window.localStorage[key];
      if (raw == null) {
        final init = {"assignments": [], "grades": []};
        html.window.localStorage[key] = jsonEncode(init);
        return init;
      }
      final data = jsonDecode(raw) as Map<String, dynamic>;
      data['assignments'] = (data['assignments'] as List<dynamic>?) ?? [];
      data['grades'] = (data['grades'] as List<dynamic>?) ?? [];
      return data;
    } catch (e) {
      return {"assignments": [], "grades": []};
    }
  }

  Future<void> writeCourseData(String courseId, Map<String, dynamic> data) async {
    final key = _keyForCourse(courseId);
    html.window.localStorage[key] = jsonEncode(data);
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
      final key = _keyForCourse(courseId);
      html.window.localStorage.remove(key);
    } catch (_) {}
  }
}
