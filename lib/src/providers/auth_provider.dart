import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthState {
  final bool isAuthenticated;
  AuthState({required this.isAuthenticated});
}

final authStateProvider = StateProvider<AuthState>((ref) => AuthState(isAuthenticated: false));
