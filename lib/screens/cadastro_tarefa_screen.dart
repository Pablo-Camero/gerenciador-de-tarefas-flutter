import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class CadastroTarefaScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const CadastroTarefaScreen({super.key, this.tarefa});

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final _authService = AuthService();
  final _firebaseService = FirebaseService();

  DateTime? _dataVencimento;
  String _prioridade = 'Média';
  bool _concluida = false;
  bool _salvando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();

    final tarefa = widget.tarefa;

    if (tarefa != null) {
      _tituloController.text = tarefa.titulo;
      _descricaoController.text = tarefa.descricao;
      _dataVencimento = tarefa.dataVencimento;
      _prioridade = tarefa.prioridade;
      _concluida = tarefa.concluida;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: _dataVencimento ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        _dataVencimento = data;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataVencimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de vencimento.')),
      );
      return;
    }

    final usuario = _authService.usuarioAtual;

    if (usuario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não autenticado.')));
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final tarefa = Tarefa(
        id: widget.tarefa?.id ?? _firebaseService.gerarIdTarefa(usuario.uid),
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataVencimento: _dataVencimento!,
        prioridade: _prioridade,
        concluida: _concluida,
      );

      if (_editando) {
        await _firebaseService.atualizarTarefa(usuario.uid, tarefa);
      } else {
        await _firebaseService.salvarTarefa(usuario.uid, tarefa);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Tarefa atualizada com sucesso!'
                : 'Tarefa cadastrada com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar tarefa: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar Tarefa' : 'Nova Tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título da tarefa';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _selecionarData,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _dataVencimento == null
                      ? 'Selecionar vencimento'
                      : 'Vencimento: '
                            '${_dataVencimento!.day.toString().padLeft(2, '0')}/'
                            '${_dataVencimento!.month.toString().padLeft(2, '0')}/'
                            '${_dataVencimento!.year}',
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _prioridade,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                ),
                items: ['Baixa', 'Média', 'Alta']
                    .map(
                      (prioridade) => DropdownMenuItem(
                        value: prioridade,
                        child: Text(prioridade),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _prioridade = valor;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Tarefa concluída'),
                value: _concluida,
                onChanged: (valor) {
                  setState(() {
                    _concluida = valor;
                  });
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_editando ? 'Salvar Alterações' : 'Salvar Tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
