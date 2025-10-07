// lib/src/services/api_client.dart
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'json_storage.dart';

class ApiClient {
  final Dio dio;
  ApiClient._(this.dio);

  factory ApiClient({String? token}) {
    final dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
    ));
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return ApiClient._(dio);
  }

  Future<Response> get(String path) async {
    if (useFakeApi) {
      await Future.delayed(const Duration(milliseconds: 250));
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: await _fakeGet(path),
      );
    }
    return dio.get(path);
  }

  Future<Response> post(String path, {dynamic data}) async {
    if (useFakeApi) {
      await Future.delayed(const Duration(milliseconds: 250));
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 201,
        data: await _fakePost(path, data),
      );
    }
    return dio.post(path, data: data);
  }

  // --- helpers for fake mode that now persist to JSON ---
  Future<Map<String, dynamic>> _fakeGet(String path) async {
    // /auth/me
    if (path == '/auth/me') {
      return {
        "id": "u1",
        "name": "Prof. João",
        "ra": "123456",
        "role": "teacher",
      };
    }

    // /courses
    if (path == '/courses') {
      return {
        "items": [
          {
            "id": "c1",
            "code": "MAT101",
            "title": "Cálculo I",
            "description": "Fundamentos de cálculo diferencial e integral."
          },
          {
            "id": "c2",
            "code": "PROG202",
            "title": "Programação II",
            "description": "Estruturas de dados e algoritmos."
          }
        ]
      };
    }

    // /courses/{id}/students
    if (path.contains('/courses/') && path.endsWith('/students')) {
      final parts = path.split('/');
      final courseId = parts[2];
      // For demo, return static students
      return {
        "items": [
          {"id": "s1", "name": "Ana Silva", "ra": "2019001", "role": "student"},
          {"id": "s2", "name": "Bruno Costa", "ra": "2019002", "role": "student"},
          {"id": "s3", "name": "Carla Souza", "ra": "2019003", "role": "student"},
        ]
      };
    }

    // /courses/{id}
    if (path.contains('/courses/')) {
      final parts = path.split('/');
      final courseId = parts[2];

      // base fake course payload
      final base = {
        "id": courseId,
        "code": "MAT101",
        "title": "Cálculo I",
        "description": "Disciplina exemplo do projeto.",
        "materials": [
          {"id": "m1", "title": "Aula 01 - Introdução", "fileUrl": "#"},
          {"id": "m2", "title": "Aula 02 - Derivadas", "fileUrl": "#"}
        ],
        "assignments": [
          {
            "id": "a1",
            "title": "Lista 1",
            "description": "Exercícios sobre limites.",
            "dueDate": DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            "weight": 1.0
          }
        ],
        // some default grade snapshot
        "grades": [
          {"studentId": "s1", "studentName": "Ana Silva", "finalGrade": 8.5},
          {"studentId": "s2", "studentName": "Bruno Costa", "finalGrade": 7.0}
        ]
      };

      // Merge with persisted JSON if exists
      try {
        final stored = await JsonStorage.instance.readCourseData(courseId);
        // stored['assignments'] and stored['grades'] are lists
        final persistedAssignments = (stored['assignments'] as List<dynamic>).cast<Map<String, dynamic>>();
        final persistedGrades = (stored['grades'] as List<dynamic>).cast<Map<String, dynamic>>();

        // ensure any persisted assignments have string dates
        final cleanedAssignments = persistedAssignments.map((a) {
          final copy = Map<String, dynamic>.from(a);
          if (copy['dueDate'] is DateTime) {
            copy['dueDate'] = (copy['dueDate'] as DateTime).toIso8601String();
          }
          return copy;
        }).toList();

        // merge: base.assignments + cleaned persisted assignments
        final mergedAssignments = <Map<String, dynamic>>[];
        mergedAssignments.addAll((base['assignments'] as List).cast<Map<String, dynamic>>());
        mergedAssignments.addAll(cleanedAssignments);

        final mergedGrades = <Map<String, dynamic>>[];
        mergedGrades.addAll((base['grades'] as List).cast<Map<String, dynamic>>());
        mergedGrades.addAll(persistedGrades);

        base['assignments'] = mergedAssignments;
        base['grades'] = mergedGrades;
      } catch (_) {
        // ignore, use base
      }

      return base;
    }

    // default
    return {};
  }

  Future<Map<String, dynamic>> _fakePost(String path, dynamic data) async {
    // POST /courses/{id}/assignments -> create assignment and persist
    if (path.contains('/courses/') && path.contains('/assignments')) {
      final parts = path.split('/');
      final courseId = parts[2];
      final now = DateTime.now();
      final id = 'a${now.millisecondsSinceEpoch}';
      final assignment = {
        'id': id,
        'title': data['title'] ?? 'Nova Atividade',
        'description': data['description'] ?? '',
        'dueDate': (data['dueDate'] is String) ? data['dueDate'] : DateTime.tryParse(data['dueDate']?.toString() ?? '')?.toIso8601String() ?? now.toIso8601String(),
        'weight': (data['weight'] ?? 1.0).toDouble(),
        // we can store created_at for later db migration
        'createdAt': now.toIso8601String(),
      };

      await JsonStorage.instance.appendAssignment(courseId, assignment);
      return assignment;
    }

    // POST /courses/{id}/grades -> persist grade
    if (path.contains('/courses/') && path.contains('/grades')) {
      final parts = path.split('/');
      final courseId = parts[2];
      // normalize payload keys
      final grade = {
        'studentId': data['studentId'],
        'studentName': data['studentName'] ?? data['studentName'],
        'assignmentId': data['assignmentId'],
        'score': (data['score'] is num) ? (data['score'] as num).toDouble() : double.tryParse('${data['score']}') ?? 0.0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await JsonStorage.instance.appendGrade(courseId, grade);
      return {'ok': true, 'saved': grade};
    }

    // default: return given payload
    return {"ok": true, "payload": data ?? {}};
  }
}
