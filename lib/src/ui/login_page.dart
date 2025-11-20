import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _raCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final authSvc = ref.watch(authServiceProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// Fundo com degradê azul → amarelo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1FB1C2), // Azul
              Color(0xFFFFC66E), // Amarelo
            ],
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 80),

            /// LOGO
            Center(
              child: Image.asset(
                'assets/images/logopoliedro.png',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            /// CARD DE LOGIN
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          /// Campo RA
                          TextField(
                            controller: _raCtrl,
                            decoration: const InputDecoration(
                              labelText: 'RA',
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 12),

                          /// Campo Senha
                          TextField(
                            controller: _passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (error != null)
                            Text(
                              error!,
                              style: const TextStyle(color: Colors.red),
                            ),

                          const SizedBox(height: 12),

                          /// BOTÃO ENTRAR
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: loading
                                  ? null
                                  : () async {
                                      setState(() {
                                        loading = true;
                                        error = null;
                                      });

                                      final ok = await authSvc.login(
                                        _raCtrl.text.trim(),
                                        _passCtrl.text.trim(),
                                      );

                                      setState(() => loading = false);

                                      if (ok) {
                                        ref
                                            .read(authStateProvider.notifier)
                                            .state = AuthState(isAuthenticated: true);

                                        if (context.mounted) {
                                          context.go('/home');
                                        }
                                      } else {
                                        setState(() {
                                          error = 'Credenciais inválidas';
                                        });
                                      }
                                    },
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          /// Botão Demo
                          TextButton(
                            onPressed: () {
                              _raCtrl.text = 'demo';
                              _passCtrl.text = 'demo';
                            },
                            child: const Text('Usar credenciais demo'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
