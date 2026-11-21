
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/drawer_menu.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final bool temaEscuro;
  final Future<void> Function(bool) onTemaAlterado;

  const ConfiguracoesScreen({
    super.key,
    required this.temaEscuro,
    required this.onTemaAlterado,
  });

  @override
  State<ConfiguracoesScreen> createState() =>
      _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState
    extends State<ConfiguracoesScreen> {

  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  late bool _temaEscuro;
  bool _salvando = false;
  bool _excluindo = false;

  @override
  void initState() {
    super.initState();
    _temaEscuro = widget.temaEscuro;
  }

  Future<void> _alterarTema(bool valor) async {
    setState(() {
      _salvando = true;
    });

    try {
      await widget.onTemaAlterado(valor);

      if (!mounted) return;

      setState(() {
        _temaEscuro = valor;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar tema: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  Future<void> _confirmarExclusao() async {
    final senhaController = TextEditingController();

    try {
      final senha = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Excluir conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Esta ação é permanente e excluirá '
                'sua conta e todas as suas tarefas. '
                'Digite sua senha para confirmar.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  senhaController.text,
                );
              },
              child: const Text(
                'Excluir definitivamente',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (senha == null || senha.isEmpty) return;

      await _excluirConta(senha);
    } finally {
      senhaController.dispose();
    }
  }

  Future<void> _excluirConta(String senha) async {
    final usuario = _authService.usuarioAtual;

    if (usuario == null || usuario.email == null) return;

    setState(() {
      _excluindo = true;
    });

    try {
      final credencial = EmailAuthProvider.credential(
        email: usuario.email!,
        password: senha,
      );

      await usuario.reauthenticateWithCredential(
        credencial,
      );

      await _firebaseService.excluirDadosUsuario(
        usuario.uid,
      );

      await _authService.excluirConta();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          mensagem = 'Senha incorreta.';
          break;
        case 'requires-recent-login':
          mensagem = 'Faça login novamente para excluir a conta.';
          break;
        default:
          mensagem = 'Erro ao excluir conta: ${e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir conta: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _excluindo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      drawer: const DrawerMenu(),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Aparência',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              title: const Text('Tema escuro'),
              subtitle: Text(
                _temaEscuro
                    ? 'Modo escuro ativado'
                    : 'Modo claro ativado',
              ),
              secondary: Icon(
                _temaEscuro
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              value: _temaEscuro,
              onChanged: _salvando || _excluindo
                  ? null
                  : _alterarTema,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Conta',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
              title: const Text('Excluir conta'),
              subtitle: const Text(
                'Remover sua conta e todas as tarefas',
              ),
              onTap: _excluindo
                  ? null
                  : _confirmarExclusao,
            ),
          ),

          if (_excluindo)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
