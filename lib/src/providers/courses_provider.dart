// lib/src/providers/courses_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_alunos/src/providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/course_service.dart';
import '../services/student_service.dart';
import '../services/message_service.dart';
import '../services/submission_service.dart';
import '../services/material_service.dart';
import '../models/course.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/submission.dart';
import '../models/material_item.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  // Por enquanto, retorna sem token - o token será adicionado nas requisições individuais
  // quando necessário através do AuthService
  return ApiClient();
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

final updateStudentEnrollmentsProvider = Provider((ref) {
  final svc = ref.watch(studentServiceProvider);
  return (String studentId, List<String> subjectIds) async {
    return svc.updateEnrollments(studentId: studentId, subjectIds: subjectIds);
  };
});

// NEW: delete course action
final deleteCourseProvider = Provider((ref) {
  final svc = ref.watch(courseServiceProvider);
  return (String courseId) async {
    return svc.deleteCourse(courseId);
  };
});

// NEW: create course action
final createCourseProvider = Provider((ref) {
  final svc = ref.watch(courseServiceProvider);
  return ({
    required String name,
    required String code,
    String? description,
  }) async {
    return svc.createCourse(name: name, code: code, description: description);
  };
});

// Messages
final messageServiceProvider = Provider<MessageService>((ref) {
  final client = ref.watch(apiClientProvider);
  final authService = ref.watch(authServiceProvider);
  return MessageService(client, authService);
});

final messagesProvider = FutureProvider.family<List<Message>, String?>((ref, studentId) async {
  final svc = ref.watch(messageServiceProvider);
  return svc.listMessages(studentId: studentId);
});

final sendMessageProvider = Provider((ref) {
  final svc = ref.watch(messageServiceProvider);
  return ({
    required String content,
    String? toStudentId,
    String? toStudentName,
    bool broadcast = false,
  }) async {
    return svc.sendMessage(
      content: content,
      toStudentId: toStudentId,
      toStudentName: toStudentName,
      broadcast: broadcast,
    );
  };
});

final deleteMessageProvider = Provider((ref) {
  final svc = ref.watch(messageServiceProvider);
  return (String messageId) async {
    return svc.deleteMessage(messageId);
  };
});

// Submissions
final submissionServiceProvider = Provider<SubmissionService>((ref) {
  final client = ref.watch(apiClientProvider);
  return SubmissionService(client);
});

final submissionsProvider = FutureProvider.family<List<Submission>, String>((ref, assignmentId) async {
  final svc = ref.watch(submissionServiceProvider);
  return svc.listSubmissions(assignmentId);
});

final submitAssignmentProvider = Provider((ref) {
  final svc = ref.watch(submissionServiceProvider);
  return ({
    required String assignmentId,
    required String studentId,
    String? studentName,
    String? fileName,
    String? fileUrl,
    String? notes,
  }) async {
    return svc.submitAssignment(
      assignmentId: assignmentId,
      studentId: studentId,
      studentName: studentName,
      fileName: fileName,
      fileUrl: fileUrl,
      notes: notes,
    );
  };
});

// Materials
final materialServiceProvider = Provider<MaterialService>((ref) {
  final client = ref.watch(apiClientProvider);
  return MaterialService(client);
});

final materialsProvider = FutureProvider.family<List<MaterialItem>, String>((ref, courseId) async {
  final svc = ref.watch(materialServiceProvider);
  return svc.listMaterials(courseId);
});

final createMaterialProvider = Provider((ref) {
  final svc = ref.watch(materialServiceProvider);
  return ({
    required String courseId,
    required String title,
    required String fileName,
    String? fileData,
  }) async {
    return svc.createMaterial(
      courseId: courseId,
      title: title,
      fileName: fileName,
      fileData: fileData,
    );
  };
});

final downloadMaterialProvider = Provider((ref) {
  final svc = ref.watch(materialServiceProvider);
  return (String fileStorageId, {String? fileName}) async {
    return svc.downloadMaterial(fileStorageId, fileName: fileName);
  };
});