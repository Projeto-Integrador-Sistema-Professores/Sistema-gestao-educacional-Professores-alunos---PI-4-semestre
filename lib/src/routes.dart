// lib/src/routes.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/login_page.dart';
import 'ui/home_page.dart';
import 'ui/course_page.dart';
import 'ui/students_page.dart';
import 'ui/grade_launch_page.dart';
import 'ui/create_assignment_page.dart';
import 'providers/auth_provider.dart';
import 'ui/all_students_page.dart';
import 'ui/messages_page.dart';
import 'ui/assignment_detail_page.dart';
import 'ui/submit_assignment_page.dart';
import 'models/assignment.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/students',
        name: 'students_all',
        builder: (context, state) => const AllStudentsPage(),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const MessagesPage(),
      ),
      GoRoute(
        path: '/course/:id',
        name: 'course',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CoursePage(courseId: id);
        },
      ),
      GoRoute(
        path: '/course/:id/students',
        name: 'course_students',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StudentsPage(courseId: id);
        },
      ),
      GoRoute(
        path: '/course/:id/grade',
        name: 'course_grade',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final studentId = state.queryParameters['studentId'] ?? '';
          final assignmentId = state.queryParameters['assignmentId'] ?? '';
          return GradeLaunchPage(courseId: id, studentId: studentId, assignmentId: assignmentId);
        },
      ),
      GoRoute(
        path: '/course/:id/create-assignment',
        name: 'create_assignment',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CreateAssignmentPage(courseId: id);
        },
      ),
      GoRoute(
        path: '/course/:courseId/assignment/:assignmentId',
        name: 'assignment_detail',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final assignmentId = state.pathParameters['assignmentId']!;
          // Busca assignment dos query params ou cria fallback
          final title = state.queryParameters['title'] ?? 'Atividade';
          final description = state.queryParameters['description'] ?? '';
          final dueDateStr = state.queryParameters['dueDate'];
          final weightStr = state.queryParameters['weight'] ?? '1.0';
          
          DateTime dueDate = DateTime.now();
          if (dueDateStr != null) {
            dueDate = DateTime.tryParse(dueDateStr) ?? DateTime.now();
          }
          
          final assignment = Assignment(
            id: assignmentId,
            title: title,
            description: description,
            dueDate: dueDate,
            weight: double.tryParse(weightStr) ?? 1.0,
          );
          return AssignmentDetailPage(courseId: courseId, assignment: assignment);
        },
      ),
      GoRoute(
        path: '/course/:courseId/assignment/:assignmentId/submit',
        name: 'submit_assignment',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final assignmentId = state.pathParameters['assignmentId']!;
          final studentId = state.queryParameters['studentId'] ?? '';
          final studentName = state.queryParameters['studentName'];
          // Similar ao acima - na prática buscaria do provider
          final assignment = Assignment(
            id: assignmentId,
            title: state.queryParameters['title'] ?? 'Atividade',
            description: state.queryParameters['description'] ?? '',
            dueDate: DateTime.now(),
            weight: double.tryParse(state.queryParameters['weight'] ?? '1.0') ?? 1.0,
          );
          return SubmitAssignmentPage(
            courseId: courseId,
            assignment: assignment,
            studentId: studentId,
            studentName: studentName,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final loggingIn = state.location == '/';
      if (!auth.isAuthenticated && !loggingIn) return '/';
      if (auth.isAuthenticated && loggingIn) return '/home';
      return null;
    },
    debugLogDiagnostics: false,
  );
});
