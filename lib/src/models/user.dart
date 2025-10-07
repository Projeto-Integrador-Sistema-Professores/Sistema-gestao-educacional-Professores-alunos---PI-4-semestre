class User {
  final String id;
  final String name;
  final String ra;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.ra,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        ra: j['ra'] ?? '',
        role: j['role'] ?? 'student',
      );
}
