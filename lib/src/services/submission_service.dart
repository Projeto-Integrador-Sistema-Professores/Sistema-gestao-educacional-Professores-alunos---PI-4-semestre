// lib/src/services/submission_service.dart
import 'package:uuid/uuid.dart';
import 'api_client.dart';
import '../models/submission.dart';

class SubmissionService {
  final ApiClient client;
  SubmissionService(this.client);

  Future<List<Submission>> listSubmissions(String assignmentId) async {
    final res = await client.get('/assignments/$assignmentId/submissions');
    final items = (res.data['items'] as List).cast<Map<String, dynamic>>();
    return items.map((e) => Submission.fromJson(e)).toList();
  }

  Future<Submission> submitAssignment({
    required String assignmentId,
    required String studentId,
    String? studentName,
    String? fileName,
    String? fileUrl,
    String? notes,
  }) async {
    final id = const Uuid().v4();
    final payload = {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'submittedAt': DateTime.now().toIso8601String(),
      if (studentName != null) 'studentName': studentName,
      if (fileName != null) 'fileName': fileName,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (notes != null) 'notes': notes,
    };
    final res = await client.post('/assignments/$assignmentId/submissions', data: payload);
    return Submission.fromJson(res.data['submission']);
  }
}

