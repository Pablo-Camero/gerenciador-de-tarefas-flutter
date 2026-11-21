class Tarefa{
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final String prioridade;
  final bool concluida;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.concluida,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataVencimento': dataVencimento.toIso8601String(),
      'prioridade': prioridade,
      'concluida': concluida,
    };
  }

  factory Tarefa.fromMap(String id, Map<dynamic, dynamic> map) {
    return Tarefa(
      id: id,
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      dataVencimento: DateTime.tryParse(
            map['dataVencimento']?.toString() ?? '',
          ) ??
          DateTime.now(),
      prioridade: map['prioridade']?.toString() ?? 'Baixa',
      concluida: map['concluida'] == true,
    );
  }
}