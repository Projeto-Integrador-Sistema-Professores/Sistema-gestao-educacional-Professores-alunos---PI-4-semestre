import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app_name/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fluxo completo de login e logout', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final raField = find.byKey(Key('login-ra'));
    final passField = find.byKey(Key('login-password'));
    final loginBtn = find.byKey(Key('login-button'));

    await tester.enterText(raField, '200300');
    await tester.enterText(passField, 'Senha123!');
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);

    // logout
    final logoutBtn = find.byKey(Key('logout-button'));
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    expect(find.byKey(Key('login-button')), findsOneWidget);
  });
}
