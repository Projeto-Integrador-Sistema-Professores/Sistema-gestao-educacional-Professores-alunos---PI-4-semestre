import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../utils/constants.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const _keyToken = 'auth_token';

  Future<bool> login(String ra, String password) async {
    if (ra.isEmpty || password.isEmpty) return false;
    if (ra == 'demo' && password == 'demo') {
      await _storage.write(key: _keyToken, value: 'token_demo_123');
      return true;
    }
    if (useFakeApi) {
      // accept any non-empty for demo
      await _storage.write(key: _keyToken, value: 'token_demo_123');
      return true;
    } else {
      final client = ApiClient();
      final res = await client.get('/auth/login'); // adapt to real POST later
      return res.statusCode == 200;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _keyToken);
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);
}
