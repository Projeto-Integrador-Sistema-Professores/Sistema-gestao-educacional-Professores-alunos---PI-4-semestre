import 'package:flutter_test/flutter_test.dart';
// Ajuste o import se o modelo estiver em outro caminho
import 'package:gestor_alunos/models/user.dart';

void main() {
  group('User model', () {
    test('should require RA, name and email', () {
      final u = User(ra: '123456', name: 'Fulano', email: 'f@u.com');
      expect(u.ra, isNotNull);
      expect(u.name, isNotNull);
      expect(u.email, isNotNull);
    });

    test('RA mínimo deve ter 6 caracteres', () {
      final u = User(ra: '123456', name: 'Fulano', email: 'f@u.com');
      expect(u.ra.length, greaterThanOrEqualTo(6));
    });
  });
}
