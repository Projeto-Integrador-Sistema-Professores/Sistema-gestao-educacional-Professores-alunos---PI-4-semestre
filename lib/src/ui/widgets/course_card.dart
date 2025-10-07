import 'package:flutter/material.dart';
import '../../models/course.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({required this.course, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical:8),
      child: ListTile(
        title: Text(course.title),
        subtitle: Text(course.code),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/course/${course.id}');
        },
      ),
    );
  }
}
