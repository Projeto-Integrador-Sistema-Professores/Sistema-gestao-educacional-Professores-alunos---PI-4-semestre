import 'package:flutter/material.dart';
import '../../models/course.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onDelete;
  const CourseCard({required this.course, this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical:8),
      child: ListTile(
        title: Text(course.title),
        subtitle: Text(course.code),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'open') {
              context.push('/course/${course.id}');
            } else if (v == 'delete') {
              onDelete?.call();
            }
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'open', child: Text('Abrir')),
            PopupMenuItem(value: 'delete', child: Text('Excluir')),
          ],
        ),
        onTap: () {
          context.push('/course/${course.id}');
        },
      ),
    );
  }
}
