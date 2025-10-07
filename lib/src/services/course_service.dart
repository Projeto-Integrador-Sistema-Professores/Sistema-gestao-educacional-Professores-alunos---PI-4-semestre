// lib/src/services/course_service.dart
import 'api_client.dart';
import '../models/course.dart';
import '../models/material_item.dart';
import '../models/assignment.dart';
import '../models/grade.dart';
import '../models/user.dart';

class CourseService {
  final ApiClient client;
  CourseService(this.client);

  Future<List<Course>> listCourses() async {
    final res = await client.get('/courses');
    final items = (res.data['items'] as List).cast<Map<String, dynamic>>();
    return items.map((e) => Course.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getCourseDetails(String id) async {
    final res = await client.get('/courses/$id');
    final data = res.data;
    final materials = (data['materials'] as List<dynamic>).map((m) => MaterialItem.fromJson(Map<String,dynamic>.from(m))).toList();
    final assignments = (data['assignments'] as List<dynamic>).map((a) => Assignment.fromJson(Map<String,dynamic>.from(a))).toList();
    final grades = (data['grades'] as List<dynamic>?)?.map((g) => Grade.fromJson(Map<String,dynamic>.from(g))).toList() ?? [];

    return {
      'course': Course.fromJson(data),
      'materials': materials,
      'assignments': assignments,
      'grades': grades,
    };
  }

  Future<List<User>> listStudents(String courseId) async {
    final res = await client.get('/courses/$courseId/students');
    final items = (res.data['items'] as List).cast<Map<String, dynamic>>();
    return items.map((e) => User.fromJson(e)).toList();
  }

  Future<Grade> submitGrade({
    required String courseId,
    required String studentId,
    required String assignmentId,
    required double score,
  }) async {
    final payload = {
      'studentId': studentId,
      'assignmentId': assignmentId,
      'score': score,
    };
    final res = await client.post('/courses/$courseId/grades', data: payload);
    // Fake returns payload; build Grade locally
    return Grade(
      studentId: studentId,
      assignmentId: assignmentId,
      score: score,
    );
  }

  Future<Assignment> createAssignment({
    required String courseId,
    required String title,
    String? description,
    required DateTime dueDate,
    required double weight,
  }) async {
    final payload = {
      'title': title,
      'description': description ?? '',
      'dueDate': dueDate.toIso8601String(),
      'weight': weight,
    };
    final res = await client.post('/courses/$courseId/assignments', data: payload);
    return Assignment.fromJson(Map<String, dynamic>.from(res.data));
  }
}
