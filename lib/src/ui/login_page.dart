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
      appBar: AppBar(title: const Text('Entrar - Gestor de Alunos')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: _raCtrl,
                  decoration: const InputDecoration(labelText: 'RA'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
                const SizedBox(height: 16),
                if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: loading ? null : () async {
                    setState(() { loading = true; error = null; });
                    final ok = await authSvc.login(_raCtrl.text.trim(), _passCtrl.text.trim());
                    setState(() { loading = false; });
                    if (ok) {
                      ref.read(authStateProvider.notifier).state = AuthState(isAuthenticated: true);
                      if (context.mounted) context.go('/home');
                    } else {
                      setState(() { error = 'Credenciais inválidas'; });
                    }
                  },
                  child: loading ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,)) : const Text('Entrar'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _raCtrl.text = 'demo';
                    _passCtrl.text = 'demo';
                  },
                  child: const Text('Usar credenciais demo'),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
