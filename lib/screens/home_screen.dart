
import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'tarefas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  String _nomeUsuario = 'Usuário';
  String _emailUsuario = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuarioAuth = _authService.usuarioAtual;

    if (usuarioAuth == null) return;

    try {
      final usuario = await _firebaseService.buscarUsuario(
        usuarioAuth.uid,
      );

      if (!mounted) return;

      setState(() {
        _nomeUsuario = usuario?.nome ?? 'Usuário';
        _emailUsuario = usuario?.email ?? usuarioAuth.email ?? '';
      });
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
    }
  }

  Widget _cardResumo(
    String titulo,
    int quantidade,
    IconData icone,
    Color cor,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icone, color: cor, size: 30),
        title: Text(titulo),
        trailing: Text(
          quantidade.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _authService.usuarioAtual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Tarefas'),
      ),
      drawer: const DrawerMenu(),
      body: usuario == null
          ? const Center(
              child: Text('Usuário não autenticado.'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $_nomeUsuario!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _emailUsuario,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Resumo das Tarefas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  StreamBuilder<List<Tarefa>>(
                    stream: _firebaseService.listarTarefas(
                      usuario.uid,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Erro ao carregar resumo das tarefas.',
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final tarefas = snapshot.data!;

                      final total = tarefas.length;

                      final concluidas = tarefas
                          .where((tarefa) => tarefa.concluida)
                          .length;

                      final pendentes = total - concluidas;

                      return Column(
                        children: [
                          _cardResumo(
                            'Total de tarefas',
                            total,
                            Icons.list_alt,
                            Colors.blue,
                          ),

                          _cardResumo(
                            'Concluídas',
                            concluidas,
                            Icons.check_circle,
                            Colors.green,
                          ),

                          _cardResumo(
                            'Pendentes',
                            pendentes,
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TarefasScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Ver Minhas Tarefas'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
