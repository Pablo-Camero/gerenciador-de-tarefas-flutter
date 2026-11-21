import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _alterarConclusao(Tarefa tarefa) async {
    final usuario = _authService.usuarioAtual;
    if (usuario == null) return;

    final tarefaAtualizada = Tarefa(
      id: tarefa.id,
      titulo: tarefa.titulo,
      descricao: tarefa.descricao,
      dataVencimento: tarefa.dataVencimento,
      prioridade: tarefa.prioridade,
      concluida: !tarefa.concluida,
    );

    try {
      await _firebaseService.atualizarTarefa(usuario.uid, tarefaAtualizada);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar tarefa: $e')));
    }
  }

  Future<void> _excluirTarefa(Tarefa tarefa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja realmente excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final usuario = _authService.usuarioAtual;
    if (usuario == null) return;

    try {
      await _firebaseService.excluirTarefa(usuario.uid, tarefa.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa excluída com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao excluir tarefa: $e')));
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _authService.usuarioAtual;

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Tarefas')),
      drawer: const DrawerMenu(),

      body: usuario == null
          ? const Center(child: Text('Usuário não autenticado.'))
          : StreamBuilder<List<Tarefa>>(
              stream: _firebaseService.listarTarefas(usuario.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar tarefas: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tarefas = snapshot.data!;

                if (tarefas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma tarefa cadastrada ainda.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tarefas.length,

                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];

                    final estiloTexto = TextStyle(
                      decoration: tarefa.concluida
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    );

                    return Opacity(
                      opacity: tarefa.concluida ? 0.55 : 1.0,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Checkbox(
                            value: tarefa.concluida,
                            onChanged: (_) {
                              _alterarConclusao(tarefa);
                            },
                          ),

                          title: Text(
                            tarefa.titulo,
                            style: estiloTexto.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tarefa.descricao.isNotEmpty)
                                Text(tarefa.descricao, style: estiloTexto),

                              const SizedBox(height: 4),

                              Text(
                                'Vencimento: '
                                '${_formatarData(tarefa.dataVencimento)}',
                                style: estiloTexto,
                              ),

                              Text(
                                'Prioridade: ${tarefa.prioridade}',
                                style: estiloTexto,
                              ),
                            ],
                          ),

                          isThreeLine: true,

                          trailing: PopupMenuButton<String>(
                            onSelected: (opcao) {
                              if (opcao == 'editar') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CadastroTarefaScreen(tarefa: tarefa),
                                  ),
                                );
                              }

                              if (opcao == 'excluir') {
                                _excluirTarefa(tarefa);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              const PopupMenuItem(
                                value: 'excluir',
                                child: Text('Excluir'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroTarefaScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
