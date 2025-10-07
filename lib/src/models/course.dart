class Course {
  final String id;
  final String code;
  final String title;
  final String description;

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
  });

  factory Course.fromJson(Map<String, dynamic> j) => Course(
        id: j['id'] ?? '',
        code: j['code'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
      );
}
