// lib/src/services/submission_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SubmissionStorage {
  static const String _key = 'submissions_list';

  Future<List<Map<String, dynamic>>> loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveSubmissions(List<Map<String, dynamic>> submissions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(submissions));
  }

  Future<void> addSubmission(Map<String, dynamic> submission) async {
    final list = await loadSubmissions();
    // Remove submission anterior do mesmo aluno para a mesma atividade (substitui)
    list.removeWhere((s) => 
      s['assignmentId'] == submission['assignmentId'] && 
      s['studentId'] == submission['studentId']
    );
    list.add(submission);
    await saveSubmissions(list);
  }

  Future<List<Map<String, dynamic>>> getSubmissionsForAssignment(String assignmentId) async {
    final all = await loadSubmissions();
    return all.where((s) => s['assignmentId'] == assignmentId).toList();
  }

  Future<Map<String, dynamic>?> getSubmission(String assignmentId, String studentId) async {
    final all = await loadSubmissions();
    try {
      return all.firstWhere(
        (s) => s['assignmentId'] == assignmentId && s['studentId'] == studentId
      );
    } catch (_) {
      return null;
    }
  }
}

