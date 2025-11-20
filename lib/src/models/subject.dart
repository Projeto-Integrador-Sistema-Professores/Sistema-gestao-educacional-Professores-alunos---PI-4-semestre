// lib/src/models/subject.dart
import 'dart:convert';

class Subject {
  final String id;
  final String name;
  final String code;

  Subject({required this.id, required this.name, required this.code});

  Subject copyWith({String? id, String? name, String? code}) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Subject.fromJson(String source) => Subject.fromMap(json.decode(source));
}
