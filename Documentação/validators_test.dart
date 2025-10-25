import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/utils/validators.dart';

void main() {
  test('validação de email aceita emails válidos', () {
    expect(isValidEmail('a@b.com'), isTrue);
    expect(isValidEmail('not-an-email'), isFalse);
  });

  test('validação de RA rejeita strings curtas', () {
    expect(isValidRA('123'), isFalse);
    expect(isValidRA('123456'), isTrue);
  });
}
