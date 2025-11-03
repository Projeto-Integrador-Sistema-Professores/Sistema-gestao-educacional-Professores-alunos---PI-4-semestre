import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentStorage {
  static const String _studentsKey = 'students_list';
  static const String _enrollmentsKey = 'students_enrollments'; // studentId -> [subjectId]

  Future<List<Map<String, dynamic>>> loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_studentsKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveStudents(List<Map<String, dynamic>> students) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentsKey, json.encode(students));
  }

  Future<void> addStudent(Map<String, dynamic> student) async {
    final list = await loadStudents();
    list.add(student);
    await saveStudents(list);
  }

  Future<void> removeStudent(String id) async {
    final list = await loadStudents();
    list.removeWhere((s) => (s['id'] ?? '') == id);
    await saveStudents(list);
    // also remove enrollments for that student
    final prefs = await SharedPreferences.getInstance();
    final map = await loadEnrollments();
    map.remove(id);
    await prefs.setString(_enrollmentsKey, json.encode(map));
  }

  Future<Map<String, List<String>>> loadEnrollments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_enrollmentsKey);
    if (raw == null || raw.isEmpty) return {};
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()));
  }

  Future<void> saveEnrollments(Map<String, List<String>> enrollments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_enrollmentsKey, json.encode(enrollments));
  }
}


