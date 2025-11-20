// lib/src/models/submission.dart
class Submission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String? studentName;
  final String? fileName;
  final String? fileUrl; // URL ou path do arquivo
  final DateTime submittedAt;
  final String? notes; // Observações do aluno

  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    this.fileName,
    this.fileUrl,
    required this.submittedAt,
    this.notes,
  });

  factory Submission.fromJson(Map<String, dynamic> j) {
    DateTime parsedDate;
    final date = j['submittedAt'];
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      parsedDate = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(date);
    } else {
      parsedDate = DateTime.now();
    }

    return Submission(
      id: j['id']?.toString() ?? '',
      assignmentId: j['assignmentId']?.toString() ?? '',
      studentId: j['studentId']?.toString() ?? '',
      studentName: j['studentName']?.toString(),
      fileName: j['fileName']?.toString(),
      fileUrl: j['fileUrl']?.toString(),
      submittedAt: parsedDate,
      notes: j['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assignmentId': assignmentId,
        'studentId': studentId,
        if (studentName != null) 'studentName': studentName,
        if (fileName != null) 'fileName': fileName,
        if (fileUrl != null) 'fileUrl': fileUrl,
        'submittedAt': submittedAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}

