import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_app_name/services/auth_service.dart';
import 'package:your_app_name/repositories/user_repository.dart';

class MockUserRepo extends Mock implements UserRepository {}

void main() {
  late MockUserRepo mockRepo;
  late AuthService authService;

  setUp(() {
    mockRepo = MockUserRepo();
    authService = AuthService(userRepo: mockRepo);
  });

  test('login com credenciais válidas retorna token', () async {
    when(() => mockRepo.login('200300', 'Senha123!'))
      .thenAnswer((_) async => 'token-xyz');

    final token = await authService.login('200300', 'Senha123!');
    expect(token, isNotNull);
    expect(token, contains('token'));
  });

  test('login com senha inválida lança erro', () async {
    when(() => mockRepo.login('200300', 'errada'))
      .thenThrow(AuthException('Credenciais inválidas'));

    expect(() => authService.login('200300', 'errada'), throwsA(isA<AuthException>()));
  });
}
