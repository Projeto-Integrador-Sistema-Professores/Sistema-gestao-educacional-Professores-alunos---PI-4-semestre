// lib/src/providers/courses_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/course_service.dart';
import '../services/student_service.dart';
import '../models/course.dart';
import '../models/user.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(); // for simplicity; can read token from auth service
});

final courseServiceProvider = Provider<CourseService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CourseService(client);
});

final studentServiceProvider = Provider<StudentService>((ref) {
  final client = ref.watch(apiClientProvider);
  return StudentService(client);
});

final coursesListProvider = FutureProvider<List<Course>>((ref) async {
  final svc = ref.watch(courseServiceProvider);
  return svc.listCourses();
});

final courseDetailProvider = FutureProvider.family<Map<String,dynamic>, String>((ref, id) async {
  final svc = ref.watch(courseServiceProvider);
  return svc.getCourseDetails(id);
});

// NEW: students list for a course
final studentsListProvider = FutureProvider.family<List<User>, String>((ref, courseId) async {
  final svc = ref.watch(courseServiceProvider);
  return svc.listStudents(courseId);
});

// NEW: submit grade action as AsyncNotifier (returns Grade)
final submitGradeProvider = Provider((ref) {
  final svc = ref.watch(courseServiceProvider);
  return (String courseId, String studentId, String assignmentId, double score) async {
    return svc.submitGrade(
      courseId: courseId,
      studentId: studentId,
      assignmentId: assignmentId,
      score: score,
    );
  };
});

// NEW: create assignment action
final createAssignmentProvider = Provider((ref) {
  final svc = ref.watch(courseServiceProvider);
  return (String courseId, String title, String description, DateTime dueDate, double weight) async {
    return svc.createAssignment(
      courseId: courseId,
      title: title,
      description: description,
      dueDate: dueDate,
      weight: weight,
    );
  };
});

// Students (globais)
final allStudentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final svc = ref.watch(studentServiceProvider);
  return svc.listAllWithSubjects();
});

final createStudentProvider = Provider((ref) {
  final svc = ref.watch(studentServiceProvider);
  return (String name, String ra) async {
    return svc.createStudent(name: name, ra: ra);
  };
});

// NEW: delete course action
final deleteCourseProvider = Provider((ref) {
  final svc = ref.watch(courseServiceProvider);
  return (String courseId) async {
    return svc.deleteCourse(courseId);
  };
});