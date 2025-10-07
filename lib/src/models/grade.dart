// lib/src/models/grade.dart
class Grade {
  final String studentId;
  final String? studentName;
  final String? assignmentId;
  final double? finalGrade; // field used in UI snapshot
  final double? score; // used when submitting

  Grade({
    required this.studentId,
    this.studentName,
    this.assignmentId,
    this.finalGrade,
    this.score,
  });

  factory Grade.fromJson(Map<String, dynamic> j) => Grade(
        studentId: j['studentId'] ?? '',
        studentName: j['studentName'] ?? j['studentName'],
        assignmentId: j['assignmentId'] ?? j['assignmentId'],
        // try multiple keys for compatibility
        finalGrade: j['finalGrade'] != null ? (j['finalGrade'] as num).toDouble() : (j['score'] != null ? (j['score'] as num).toDouble() : null),
        score: j['score'] != null ? (j['score'] as num).toDouble() : null,
      );

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        if (studentName != null) 'studentName': studentName,
        if (assignmentId != null) 'assignmentId': assignmentId,
        if (finalGrade != null) 'finalGrade': finalGrade,
        if (score != null) 'score': score,
      };
}
