import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/user.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return null;
    
    // Credenciais demo para aluno
    if (username == 'demo@poliedro' && password == 'demo') {
      final user = {
        'id': 'demo_student_1',
        'name': 'Aluno Demo',
        'ra': '2024001',
        'role': 'student',
      };
      final token = 'demo_student_token';
      await _storage.write(key: _keyToken, value: token);
      return {'token': token, 'user': user};
    }
    
    // Credenciais demo para professor
    if (username == 'demo' && password == 'demo') {
      final user = {
        'id': 'demo_teacher_1',
        'name': 'Prof. Demo',
        'ra': '123456',
        'role': 'teacher',
      };
      final token = 'demo_teacher_token';
      await _storage.write(key: _keyToken, value: token);
      return {'token': token, 'user': user};
    }
    
    if (useFakeApi) {
      // Para fake API, aceita qualquer login e determina role pelo formato
      final isStudent = username.contains('@poliedro');
      final user = {
        'id': isStudent ? 'student_${username.hashCode}' : 'teacher_${username.hashCode}',
        'name': isStudent ? username.split('@')[0] : username,
        'ra': password,
        'role': isStudent ? 'student' : 'teacher',
      };
      final token = 'token_demo_${user['id']}';
      await _storage.write(key: _keyToken, value: token);
      return {'token': token, 'user': user};
    }
    
    try {
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      
      final response = await dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;
        
        await _storage.write(key: _keyToken, value: token);
        
        return {
          'token': token,
          'user': userData,
        };
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);
  
  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      if (useFakeApi) {
        // Retorna usuário mock para demo baseado no token
        if (token == 'demo_student_token') {
          return User(
            id: 'demo_student_1',
            name: 'Aluno Demo',
            ra: '2024001',
            role: 'student',
          );
        } else if (token == 'demo_teacher_token') {
          return User(
            id: 'demo_teacher_1',
            name: 'Prof. Demo',
            ra: '123456',
            role: 'teacher',
          );
        }
        // Fallback genérico
        return User(
          id: 'u1',
          name: 'Usuário Demo',
          ra: '123456',
          role: 'teacher',
        );
      }
      
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ));
      
      final response = await dio.get('/auth/me');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return User(
          id: data['id'] as String,
          name: data['name'] as String,
          ra: data['ra'] as String,
          role: data['role'] as String,
        );
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }
}
