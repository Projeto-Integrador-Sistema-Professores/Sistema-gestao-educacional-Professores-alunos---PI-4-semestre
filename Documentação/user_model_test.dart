import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/models/user.dart';

void main() {
  test('RA deve ser obrigatório e ter formato básico', () {
    final u = User(ra: '123456', name: 'Fulano', email: 'f@u.com');
    expect(u.ra, isNotNull);
    expect(u.ra.length, greaterThanOrEqualTo(6));
  });
}
