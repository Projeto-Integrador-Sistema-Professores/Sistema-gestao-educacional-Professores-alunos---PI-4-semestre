import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Ajuste os imports conforme a estrutura do projeto
import 'package:gestor_alunos/services/auth_service.dart';
import 'package:gestor_alunos/repositories/user_repository.dart';

class MockUserRepo extends Mock implements UserRepository {}

void main() {
  late MockUserRepo mockRepo;
  late AuthService authService;

  setUp(() {
    mockRepo = MockUserRepo();
    authService = AuthService(userRepo: mockRepo);
  });

  test('login com credenciais válidas retorna token', () async {
    when(() => mockRepo.login('RA200300', 'Senha123!'))
      .thenAnswer((_) async => 'token-abc-123');

    final token = await authService.login('RA200300', 'Senha123!');
    expect(token, isNotNull);
    expect(token, contains('token'));
  });

  test('login com senha inválida lança AuthException', () async {
    when(() => mockRepo.login('RA200300', 'errada'))
      .thenThrow(AuthException('Credenciais inválidas'));

    expect(() => authService.login('RA200300', 'errada'), throwsA(isA<AuthException>()));
  });
}
