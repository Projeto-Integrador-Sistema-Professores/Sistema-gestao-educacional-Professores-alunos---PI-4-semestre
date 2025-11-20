import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthState {
  final bool isAuthenticated;
  final User? user;
  AuthState({required this.isAuthenticated, this.user});
}

final authStateProvider = StateProvider<AuthState>((ref) => AuthState(isAuthenticated: false));
