// lib/src/services/api_client.dart
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'json_storage.dart';

// MUDANÇA: Importar o storage de matérias e o modelo
import 'subject_storage.dart';
import '../models/subject.dart';

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

  // MUDANÇA: Removemos o _fakeCourseDb. Agora vamos ler do SubjectStorage.

  // MUDANÇA: Simplificamos o _fakeStudentsDb para ter um padrão genérico
  final _fakeStudentsDb = {
    "c1": {
      "items": [
        {"id": "s1", "name": "Ana Silva", "ra": "2019001", "role": "student"},
        {"id": "s2", "name": "Bruno Costa", "ra": "2019002", "role": "student"},
        {"id": "s3", "name": "Carla Souza", "ra": "2019003", "role": "student"},
      ]
    },
    "c2": {
      "items": [
        {"id": "s4", "name": "Daniel Moreira", "ra": "2019004", "role": "student"},
        {"id": "s5", "name": "Elisa Fernandes", "ra": "2019005", "role": "student"},
      ]
    },
    // Lista padrão para qualquer outra matéria
    "default": {
      "items": [
        {"id": "s10", "name": "Aluno Genérico 1", "ra": "2025001", "role": "student"},
        {"id": "s11", "name": "Aluno Genérico 2", "ra": "2025002", "role": "student"},
      ]
    }
  };


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
      // MUDANÇA: Carrega a lista de matérias do SubjectStorage
      final storage = SubjectStorage();
      final subjects = await storage.loadSubjects();

      // Mapeia de List<Subject> para o formato JSON que a API espera
      final items = subjects.map((s) {
        return {
          "id": s.id,
          // "code": s.room ?? "SALA-??", // Usando "room" como "code"
          "title": s.name,
          // "description": s.professor ?? "Sem professor", // Usando "professor" como "description"
        };
      }).toList();

      // Adiciona as matérias "base" se não estiverem lá (opcional, mas bom para demo)
      if (items.indexWhere((item) => item['id'] == 'c1') == -1) {
        items.insert(0, {
            "id": "c1",
            "code": "MAT101",
            "title": "Cálculo I (Base)",
            "description": "Fundamentos de cálculo diferencial e integral."
          });
      }
       if (items.indexWhere((item) => item['id'] == 'c2') == -1) {
        items.insert(1, {
            "id": "c2",
            "code": "PROG202",
            "title": "Programação II (Base)",
            "description": "Estruturas de dados e algoritmos."
          });
      }

      return {"items": items};
    }

    // /courses/{id}/students
    if (path.contains('/courses/') && path.endsWith('/students')) {
      final parts = path.split('/');
      final courseId = parts[2];
      
      // MUDANÇA: Retorna a lista de alunos para c1, c2, ou a lista "default"
      return _fakeStudentsDb[courseId] ?? _fakeStudentsDb['default']!;
    }

    // /courses/{id}
    if (path.contains('/courses/')) {
      final parts = path.split('/');
      final courseId = parts[2];

      // MUDANÇA: Busca os detalhes da matéria no SubjectStorage
      final storage = SubjectStorage();
      final subjects = await storage.loadSubjects();
      Subject? subject;
      try {
        subject = subjects.firstWhere((s) => s.id == courseId);
      } catch (e) {
        subject = null; // Não encontrou
      }

      Map<String, dynamic> base;

      if (subject != null) {
        // Encontrou a matéria no SubjectStorage. Cria um "base payload" com ela.
        base = {
          "id": subject.id,
          // "code": subject.room ?? "SALA-??",
          "title": subject.name,
          // "description": subject.professor ?? "Sem professor",
          "materials": [], // Lista vazia, será preenchida pelo JSON
          "assignments": [], // Lista vazia, será preenchida pelo JSON
          "grades": [], // Lista vazia, será preenchida pelo JSON
        };
      } else if (courseId == 'c1') {
         // Fallback para as matérias base (caso não estejam no SubjectStorage)
         base = {
            "id": "c1", "code": "MAT101", "title": "Cálculo I (Base)",
            "description": "Disciplina exemplo.",
            "materials": [{"id": "m1", "title": "Aula 01 - Intro", "fileUrl": "#"}],
            "assignments": [], "grades": []
         };
      } else if (courseId == 'c2') {
         // Fallback para as matérias base
         base = {
            "id": "c2", "code": "PROG202", "title": "Programação II (Base)",
            "description": "Disciplina exemplo.",
            "materials": [{"id": "m3", "title": "Aula 01 - Listas", "fileUrl": "#"}],
            "assignments": [], "grades": []
         };
      } else {
        // Não encontrou em lugar nenhum. Retorna uma página de erro.
        base = {
          "id": courseId,
          "code": "404",
          "title": "Matéria não encontrada",
          "description": "A matéria com ID $courseId não foi encontrada no SubjectStorage.",
          "materials": [],
          "assignments": [],
          "grades": [],
        };
      }

      // O RESTANTE DA LÓGICA É IDÊNTICA.
      // Ela mescla os dados do JSON (atividades/notas salvas) com os dados base
      // que acabamos de carregar dinamicamente.
      try {
        final stored = await JsonStorage.instance.readCourseData(courseId);
        
        final persistedAssignments = (stored['assignments'] as List<dynamic>).cast<Map<String, dynamic>>();
        final persistedGrades = (stored['grades'] as List<dynamic>).cast<Map<String, dynamic>>();

        final cleanedAssignments = persistedAssignments.map((a) {
          final copy = Map<String, dynamic>.from(a);
          if (copy['dueDate'] is DateTime) {
            copy['dueDate'] = (copy['dueDate'] as DateTime).toIso8601String();
          }
          return copy;
        }).toList();

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
    // NENHUMA MUDANÇA AQUI, JÁ ESTAVA CORRETO
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
        'createdAt': now.toIso8601String(),
      };

      await JsonStorage.instance.appendAssignment(courseId, assignment);
      return assignment;
    }

    // POST /courses/{id}/grades -> persist grade
    // NENHUMA MUDANÇA AQUI, JÁ ESTAVA CORRETO
    if (path.contains('/courses/') && path.contains('/grades')) {
      final parts = path.split('/');
      final courseId = parts[2];
      
      String studentName = data['studentName'] ?? '';
      if (studentName.isEmpty) {
        final studentList = _fakeStudentsDb[courseId]?['items'] ?? _fakeStudentsDb['default']!['items'];
        try {
          final student = studentList?.firstWhere((s) => s['id'] == data['studentId']);
          studentName = student?['name'] ?? 'Aluno Desconhecido';
        } catch (e) {
          studentName = 'Aluno (ID: ${data['studentId']})';
        }
      }

      final grade = {
        'studentId': data['studentId'],
        'studentName': studentName,
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