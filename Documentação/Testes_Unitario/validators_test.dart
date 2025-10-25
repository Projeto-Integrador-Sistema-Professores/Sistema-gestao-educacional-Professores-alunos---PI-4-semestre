import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_alunos/utils/validators.dart';

void main() {
  test('isValidEmail valida emails corretos', () {
    expect(isValidEmail('a@b.com'), isTrue);
    expect(isValidEmail('not-an-email'), isFalse);
  });

  test('isValidRA valida comprimento mínimo', () {
    expect(isValidRA('123'), isFalse);
    expect(isValidRA('123456'), isTrue);
  });
}
