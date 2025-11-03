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
