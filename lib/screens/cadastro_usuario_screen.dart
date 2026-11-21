import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/usuario.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _carregando = false;
  
  Future<void> _cadastrar() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _carregando = true;
  });

  try {
    final resultado = await _authService.cadastrarUsuario(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    final user = resultado.user;

    if (user == null) {
      throw Exception('Não foi possível obter o usuário criado.');
    }

    final usuario = Usuario(
      uid: user.uid,
      nome: _nomeController.text.trim(),
      email: user.email ?? _emailController.text.trim(),
    );

    await _firebaseService.salvarUsuario(usuario);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuário cadastrado e salvo com sucesso!'),
      ),
    );

    debugPrint('Usuário salvo no banco: ${user.uid}');

  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String mensagem;

    switch (e.code) {
      case 'email-already-in-use':
        mensagem = 'Este e-mail já está cadastrado.';
        break;
      case 'invalid-email':
        mensagem = 'O e-mail informado é inválido.';
        break;
      case 'weak-password':
        mensagem = 'A senha informada é muito fraca.';
        break;
      case 'network-request-failed':
        mensagem = 'Verifique sua conexão com a internet.';
        break;
      default:
        mensagem = 'Erro de autenticação: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );

  } on FirebaseException catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Conta criada, mas não foi possível salvar os dados: ${e.message ?? e.code}',
        ),
      ),
    );

  } catch (e) {
    if (!mounted) return;

    debugPrint('Erro no cadastro: $e');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ocorreu um erro inesperado no cadastro.'),
      ),
    );

  } finally {
    if (mounted) {
      setState(() {
        _carregando = false;
      });
    }
  }
}

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(value.trim())) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _carregando ? null : _cadastrar,
                child: _carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
