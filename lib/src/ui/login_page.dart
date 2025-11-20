import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
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
      body: Column(
        children: [
          // Parte superior azul - agora com Container em vez de AppBar
          Container(
            height: 160, 
            width: double.infinity,
            color: const Color(0xFF1FB1C2), // Cor azul
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  'assets/images/logopoliedro.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Parte do meio com o formulário (expande)
          Expanded(
            child: Container(
              color: Colors.white, // Fundo branco para a área do formulário
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextField(
                            controller: _raCtrl,
                            decoration: const InputDecoration(
                              labelText: 'RA ou Nome@poliedro',
                              hintText: 'Para alunos: nome@poliedro | Para professores: RA',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              hintText: 'Para alunos: RA | Para professores: senha',
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (error != null)
                            Text(error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: loading
                                ? null
                                : () async {
                                    setState(() {
                                      loading = true;
                                      error = null;
                                    });
                                    final result = await authSvc.login(
                                        _raCtrl.text.trim(), _passCtrl.text.trim());
                                    setState(() {
                                      loading = false;
                                    });
                                    if (result != null) {
                                      final user = User.fromJson(result['user'] as Map<String, dynamic>);
                                      ref.read(authStateProvider.notifier).state =
                                          AuthState(isAuthenticated: true, user: user);
                                      if (context.mounted) context.go('/home');
                                    } else {
                                      setState(() {
                                        error = 'Credenciais inválidas';
                                      });
                                    }
                                  },
                            child: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Entrar'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _raCtrl.text = 'demo';
                                  _passCtrl.text = 'demo';
                                },
                                child: const Text('Demo Professor'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _raCtrl.text = 'demo@poliedro';
                                  _passCtrl.text = 'demo';
                                },
                                child: const Text('Demo Aluno'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Parte inferior amarela
          Container(
            height: 160, 
            width: double.infinity,
            color: const Color(0xFFFFC66E),
          ),
        ],
      ),
    );
  }
}