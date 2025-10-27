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

  // MUDANÇA: Adicionado um "banco de dados" fake para os detalhes das matérias
  final _fakeCourseDb = {
    "c1": {
      "id": "c1",
      "code": "MAT101",
      "title": "Cálculo I",
      "description": "Fundamentos de cálculo diferencial e integral.",
      "materials": [
        {"id": "m1", "title": "Aula 01 - Introdução", "fileUrl": "#"},
        {"id": "m2", "title": "Aula 02 - Derivadas", "fileUrl": "#"}
      ],
      "assignments": [
        // Lista base de atividades (será mesclada com o JSON)
        {
          "id": "a1-base",
          "title": "Lista 1 (Base)",
          "description": "Exercícios sobre limites.",
          "dueDate": DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          "weight": 1.0
        }
      ],
      "grades": [
        // Lista base de notas (será mesclada com o JSON)
        {"studentId": "s1", "studentName": "Ana Silva", "finalGrade": 8.5},
        {"studentId": "s2", "studentName": "Bruno Costa", "finalGrade": 7.0}
      ]
    },
    "c2": {
      "id": "c2",
      "code": "PROG202",
      "title": "Programação II",
      "description": "Estruturas de dados e algoritmos.",
      "materials": [
        {"id": "m3", "title": "Aula 01 - Listas", "fileUrl": "#"},
        {"id": "m4", "title": "Aula 02 - Árvores", "fileUrl": "#"}
      ],
      "assignments": [
        // Lista base de atividades (será mesclada com o JSON)
        {
          "id": "a2-base",
          "title": "Trabalho 1 (Base)",
          "description": "Implementar lista encadeada.",
          "dueDate": DateTime.now().add(const Duration(days: 10)).toIso8601String(),
          "weight": 2.0
        }
      ],
      "grades": [
        // Lista base de notas (será mesclada com o JSON)
         {"studentId": "s3", "studentName": "Carla Souza", "finalGrade": 9.0}
      ]
    }
  };

  // MUDANÇA: Adicionado um "banco de dados" fake para as listas de alunos
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
      // Retorna a lista de matérias (isso está correto)
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
      
      // MUDANÇA: Retorna a lista de alunos com base no courseId
      return _fakeStudentsDb[courseId] ?? {"items": []};
    }

    // /courses/{id}
    if (path.contains('/courses/')) {
      final parts = path.split('/');
      final courseId = parts[2];

      // MUDANÇA: Pega os dados base do nosso "banco de dados" fake
      // Se não encontrar, usa 'c1' como padrão para evitar erros.
      final baseData = _fakeCourseDb[courseId] ?? _fakeCourseDb['c1']!; 
      
      // Copia os dados base para um novo mapa para podermos modificá-lo
      final base = Map<String, dynamic>.from(baseData);
      // Garante que as listas internas também sejam cópias
      base['materials'] = List<Map<String, dynamic>>.from(base['materials'] as List);
      base['assignments'] = List<Map<String, dynamic>>.from(base['assignments'] as List);
      base['grades'] = List<Map<String, dynamic>>.from(base['grades'] as List);


      // O RESTANTE DA LÓGICA É IDÊNTICA AO SEU CÓDIGO ORIGINAL.
      // Ela mescla os dados do JSON com os dados base que acabamos de carregar.
      try {
        final stored = await JsonStorage.instance.readCourseData(courseId);
        
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
        // A lista base (do _fakeCourseDb) é mostrada primeiro
        final mergedAssignments = <Map<String, dynamic>>[];
        mergedAssignments.addAll((base['assignments'] as List).cast<Map<String, dynamic>>());
        mergedAssignments.addAll(cleanedAssignments);

        // merge: base.grades + cleaned persisted grades
        // A lista base (do _fakeCourseDb) é mostrada primeiro
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
      
      // MUDANÇA: Lógica para buscar o nome do aluno se não for fornecido
      String studentName = data['studentName'] ?? '';
      if (studentName.isEmpty) {
        // Tenta encontrar o nome do aluno na lista fake
        final studentList = _fakeStudentsDb[courseId]?['items'] ?? [];
        try {
          final student = studentList.firstWhere((s) => s['id'] == data['studentId']);
          studentName = student['name'] ?? 'Aluno Desconhecido';
        } catch (e) {
          studentName = 'Aluno (ID: ${data['studentId']})';
        }
      }

      final grade = {
        'studentId': data['studentId'],
        'studentName': studentName, // Usa o nome que encontramos
        'assignmentId': data['assignmentId'],
        'score': (data['score'] is num) ? (data['score'] as num).toDouble() : double.tryParse('${data['score']}') ?? 0.0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await JsonStorage.instance.appendGrade(courseId, grade);
      // Retorna os dados salvos para que a UI possa ser atualizada (se necessário)
      return {'ok': true, 'saved': grade};
    }

    // default: return given payload
    return {"ok": true, "payload": data ?? {}};
  }
}