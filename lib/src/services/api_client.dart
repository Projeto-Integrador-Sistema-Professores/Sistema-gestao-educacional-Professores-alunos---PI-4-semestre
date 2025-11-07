// lib/src/services/api_client.dart
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'json_storage.dart';
import 'subject_storage.dart';
import '../models/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_storage.dart';
import 'message_storage.dart';
import 'submission_storage.dart';

class ApiClient {
  final Dio dio;
  ApiClient._(this.dio);

  List<Subject>? _cachedSubjects;

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

  Future<Response> put(String path, {dynamic data}) async {
    if (useFakeApi) {
      await Future.delayed(const Duration(milliseconds: 250));
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: await _fakePut(path, data),
      );
    }
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    if (useFakeApi) {
      await Future.delayed(const Duration(milliseconds: 200));
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: await _fakeDelete(path),
      );
    }
    return dio.delete(path);
  }

  // --- helpers for fake mode that now persist to JSON ---

  final _fakeStudentsDb = {
    "c1": {
      "items": [
        {"id": "s1", "name": "Ana Silva", "ra": "2019001", "role": "student"},
        {"id": "s2", "name": "Bruno Costa", "ra": "2019002", "role": "student"},
      ]
    },
    "c2": {
      "items": [
        {"id": "s4", "name": "Daniel Moreira", "ra": "2019004", "role": "student"},
        {"id": "s5", "name": "Elisa Fernandes", "ra": "2019005", "role": "student"},
      ]
    },
    "default": {
      "items": [
        {"id": "s10", "name": "Aluno Genérico 1", "ra": "2025001", "role": "student"},
      ]
    }
  };


  Future<Map<String, dynamic>> _fakeGet(String path) async {
    // /students (lista global)
    if (path == '/students') {
      final storage = StudentStorage();
      final students = await storage.loadStudents();
      final enrollments = await storage.loadEnrollments();

      // carrega subjects para resolver nomes
      final subjStorage = SubjectStorage();
      final subjects = await subjStorage.loadSubjects();
      final subjectMap = {for (var s in subjects) s.id: s};

      final items = students.map((s) {
        final sid = (s['id'] ?? '').toString();
        final enrolled = enrollments[sid] ?? const <String>[];
        final subjectNames = enrolled.map((id) => subjectMap[id]?.name ?? id).toList();
        return {
          'id': s['id'],
          'name': s['name'],
          'ra': s['ra'],
          'role': 'student',
          'subjects': subjectNames,
          'subjectIds': enrolled,
        };
      }).toList();

      return {'items': items};
    }

    // /messages
    if (path.startsWith('/messages')) {
      final storage = MessageStorage();
      
      // Se tem query param studentId, filtra
      if (path.contains('?')) {
        try {
          final uri = Uri.parse('http://fake$path');
          final studentId = uri.queryParameters['studentId'];
          if (studentId != null && studentId.isNotEmpty) {
            final filtered = await storage.getMessagesForStudent(studentId);
            return {'items': filtered};
          }
        } catch (_) {
          // Se falhar o parse, continua com todas as mensagens
        }
      }
      
      final allMessages = await storage.loadMessages();
      return {'items': allMessages};
    }

    // /assignments/{id}/submissions
    if (path.contains('/assignments/') && path.endsWith('/submissions')) {
      final parts = path.split('/');
      final assignmentId = parts[2];
      final storage = SubmissionStorage();
      final submissions = await storage.getSubmissionsForAssignment(assignmentId);
      return {'items': submissions};
    }

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
      final storage = SubjectStorage();
      final subjects = await storage.loadSubjects();
      
      _cachedSubjects = subjects;

      // MUDANÇA: Mapeia os dados corretos (s.code) que vêm do SubjectStorage
      // Isso corrige a lista de matérias (image_ffdf10.png)
      final items = subjects.map((s) {
        return {
          "id": s.id,
          "code": s.code, // <-- Corrigido (usava s.room)
          "title": s.name,
          // "description": s.professor ?? "Matéria de ${s.name}", // <-- Corrigido (usava s.professor)
        };
      }).toList();

      // Lê base deletadas
      final prefs = await SharedPreferences.getInstance();
      final deletedBase = prefs.getStringList('_deleted_base_courses') ?? <String>[];

      // Adiciona as matérias "base" se não estiverem no storage e não estiverem deletadas
      if (items.indexWhere((item) => item['id'] == 'c1') == -1) {
        if (!deletedBase.contains('c1')) {
          items.insert(0, {
              "id": "c1",
              "code": "MAT101",
              "title": "Cálculo I (Base)",
              "description": "Fundamentos de cálculo diferencial e integral."
            });
        }
      }
       if (items.indexWhere((item) => item['id'] == 'c2') == -1) {
        if (!deletedBase.contains('c2')) {
          items.insert(1, {
              "id": "c2",
              "code": "PROG202",
              "title": "Programação II (Base)",
              "description": "Estruturas de dados e algoritmos."
            });
        }
      }

      return {"items": items};
    }

    // /courses/{id}/students
    if (path.contains('/courses/') && path.endsWith('/students')) {
      final parts = path.split('/');
      final courseId = parts[2];
      
      // Busca alunos do StudentStorage que estão matriculados nesta matéria
      final studentStorage = StudentStorage();
      final allStudents = await studentStorage.loadStudents();
      final enrollments = await studentStorage.loadEnrollments();
      
      // Resolve o ID real da matéria (pode ser UUID ou código)
      String resolvedCourseId = courseId;
      if (courseId != 'c1' && courseId != 'c2') {
        // Tenta encontrar pelo código ou ID
        final subjStorage = SubjectStorage();
        final subjects = await subjStorage.loadSubjects();
        try {
          final subject = subjects.firstWhere(
            (s) => s.id == courseId || s.code == courseId
          );
          resolvedCourseId = subject.id;
        } catch (_) {
          // Se não encontrar, usa o courseId original
        }
      }
      
      // Filtra alunos que estão matriculados nesta matéria
      final enrolledStudents = allStudents.where((student) {
        final studentId = (student['id'] ?? '').toString();
        final studentSubjects = enrollments[studentId] ?? <String>[];
        return studentSubjects.contains(resolvedCourseId);
      }).toList();
      
      // Converte para o formato esperado pelo provider
      final items = enrolledStudents.map((s) => <String, dynamic>{
        "id": s['id'],
        "name": s['name'],
        "ra": s['ra'],
        "role": "student",
      }).toList();
      
      return {"items": items};
    }

    // /courses/{id}
    if (path.contains('/courses/')) {
      final parts = path.split('/');
      final courseId = parts[2];

      // Se base foi deletada, retorna não encontrado
      if (courseId == 'c1' || courseId == 'c2') {
        final prefs = await SharedPreferences.getInstance();
        final deletedBase = prefs.getStringList('_deleted_base_courses') ?? <String>[];
        if (deletedBase.contains(courseId)) {
          return {
            "id": courseId,
            "code": "404",
            "title": "Matéria não encontrada ($courseId)",
            "description": "Removida pelo usuário.",
            "materials": [],
            "assignments": [],
            "grades": [],
          };
        }
      }

      List<Subject> subjectsToSearch = [];
      
      if (_cachedSubjects != null) {
        subjectsToSearch = _cachedSubjects!;
      } else {
        final storage = SubjectStorage();
        subjectsToSearch = await storage.loadSubjects();
        _cachedSubjects = subjectsToSearch; 
      }
      
      Subject? subject;
      try {
        // MUDANÇA: Procura tanto pelo ID (UUID) quanto pelo CÓDIGO (ex: "FIS101")
        // Isso atende sua sugestão e torna a busca mais robusta.
        subject = subjectsToSearch.firstWhere(
          (s) => s.id == courseId || s.code == courseId
        );
      } catch (e) {
        subject = null; // Não encontrou
      }

      Map<String, dynamic> base;

      if (subject != null) {
        // MUDANÇA: Encontrou a matéria! Usa os campos corretos (name, code).
        base = {
          "id": subject.id,
          "code": subject.code, // <-- Corrigido (usava subject.room)
          "title": subject.name,
          "description": "Detalhes da matéria ${subject.name} (Código: ${subject.code})", // <-- Corrigido
          "materials": [], 
          "assignments": [],
          "grades": [],
        };
      } else if (courseId == 'c1') {
         // Fallback para as matérias base (Cálculo)
         base = {
            "id": "c1", "code": "MAT101", "title": "Cálculo I (Base)",
            "description": "Disciplina exemplo.",
            "materials": [{"id": "m1", "title": "Aula 01 - Intro", "fileUrl": "#"}],
            "assignments": [], "grades": []
         };
      } else if (courseId == 'c2') {
         // Fallback para as matérias base (Programação)
         base = {
            "id": "c2", "code": "PROG202", "title": "Programação II (Base)",
            "description": "Disciplina exemplo.",
            "materials": [{"id": "m3", "title": "Aula 01 - Listas", "fileUrl": "#"}],
            "assignments": [], "grades": []
         };
      } else {
        // Fallback genérico (o que você estava vendo antes)
        base = {
          "id": courseId,
          "code": "404",
          "title": "Matéria não encontrada ($courseId)",
          "description": "Não foi possível carregar os detalhes do SubjectStorage.",
          "materials": [],
          "assignments": [],
          "grades": [],
        };
      }

      // LÓGICA DE MERGE (igual a antes, sem mudanças)
      // Pega a 'base' que definimos acima e mescla com o JSON salvo.
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
    // POST /assignments/{id}/submissions
    if (path.contains('/assignments/') && path.contains('/submissions')) {
      final storage = SubmissionStorage();
      final payload = Map<String, dynamic>.from(data as Map);
      await storage.addSubmission(payload);
      return {'ok': true, 'submission': payload};
    }

    // POST /messages (enviar mensagem)
    if (path == '/messages') {
      final storage = MessageStorage();
      final payload = Map<String, dynamic>.from(data as Map);
      await storage.addMessage(payload);
      return {'ok': true, 'message': payload};
    }

    // POST /students (criar aluno)
    if (path == '/students') {
      final storage = StudentStorage();
      final payload = Map<String, dynamic>.from(data as Map);
      await storage.addStudent(payload);
      return {'ok': true, 'student': payload};
    }
    // Nenhuma mudança necessária aqui. O POST já estava correto.
    
    // POST /courses/{id}/assignments
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
      
      // MUDANÇA: Garante que o JsonStorage use o ID correto
      // Se o app navegou com o código (ex: "FIS101"), precisamos encontrar o ID (UUID)
      // para salvar o JSON no arquivo certo (ex: "course_ea9190....json")
      final subjectId = await _findSubjectId(courseId);
      await JsonStorage.instance.appendAssignment(subjectId, assignment);
      
      return assignment;
    }

    // POST /courses/{id}/grades
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

      // MUDANÇA: Garante que o JsonStorage use o ID correto
      final subjectId = await _findSubjectId(courseId);
      await JsonStorage.instance.appendGrade(subjectId, grade);
      
      return {'ok': true, 'saved': grade};
    }

    // default: return given payload
    return {"ok": true, "payload": data ?? {}};
  }

  Future<Map<String, dynamic>> _fakePut(String path, dynamic data) async {
    // PUT /students/{id}/enrollments
    if (path.startsWith('/students/') && path.endsWith('/enrollments')) {
      final parts = path.split('/');
      final studentId = parts[2];
      final payload = Map<String, dynamic>.from(data as Map);
      final subjects = (payload['subjects'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];

      final storage = StudentStorage();
      final enrollments = await storage.loadEnrollments();
      enrollments[studentId] = subjects;
      await storage.saveEnrollments(enrollments);
      return {'ok': true, 'studentId': studentId, 'subjects': subjects};
    }

    return {'ok': false};
  }

  Future<Map<String, dynamic>> _fakeDelete(String path) async {
    // DELETE /courses/{id}
    if (path.startsWith('/courses/')) {
      final parts = path.split('/');
      final courseId = parts[2];

      if (courseId == 'c1' || courseId == 'c2') {
        // marca como deletado nas bases
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList('_deleted_base_courses') ?? <String>[];
        if (!list.contains(courseId)) list.add(courseId);
        await prefs.setStringList('_deleted_base_courses', list);
        return {"ok": true, "deleted": courseId};
      }

      // remove do SubjectStorage
      final storage = SubjectStorage();
      await storage.removeSubject(courseId);

      // também limpa cache e dados persistidos de assignments/grades
      try {
        await JsonStorage.instance.clearCourse(courseId);
      } catch (_) {}

      // invalida cache local
      _cachedSubjects = null;
      return {"ok": true, "deleted": courseId};
    }

    return {"ok": false};
  }

  // MUDANÇA: Nova função helper para encontrar o ID (UUID) de uma matéria
  // Isso é crucial se o app navegar usando o CÓDIGO (ex: "FIS101")
  // O JsonStorage SEMPRE deve salvar usando o ID (UUID).
  Future<String> _findSubjectId(String courseIdOrCode) async {
    // Se o ID já for um dos "base" (c1, c2), retorne ele mesmo.
    if (courseIdOrCode == 'c1' || courseIdOrCode == 'c2') return courseIdOrCode;

    List<Subject> subjectsToSearch = [];
    if (_cachedSubjects != null) {
      subjectsToSearch = _cachedSubjects!;
    } else {
      final storage = SubjectStorage();
      subjectsToSearch = await storage.loadSubjects();
      _cachedSubjects = subjectsToSearch;
    }

    try {
      // Tenta encontrar a matéria pelo ID ou CÓDIGO
      final subject = subjectsToSearch.firstWhere(
        (s) => s.id == courseIdOrCode || s.code == courseIdOrCode
      );
      // Retorna o ID (UUID) verdadeiro da matéria
      return subject.id; 
    } catch(e) {
      // Se não encontrar, retorna o ID/Código original.
      // Isso vai criar um arquivo .json (ex: course_FIS101.json),
      // o que não é ideal, mas impede o app de quebrar.
      return courseIdOrCode;
    }
  }

}