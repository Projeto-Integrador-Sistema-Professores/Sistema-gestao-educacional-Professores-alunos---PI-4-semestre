// lib/src/services/subject_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';

class SubjectStorage {
  static const _key = 'subjects_list';

  Future<List<Subject>> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded.map((e) => Subject.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(subjects.map((s) => s.toMap()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<void> addSubject(Subject subject) async {
    final subjects = await loadSubjects();
    subjects.add(subject);
    await saveSubjects(subjects);
  }

  Future<void> removeSubject(String id) async {
    final subjects = await loadSubjects();
    subjects.removeWhere((s) => s.id == id);
    await saveSubjects(subjects);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
