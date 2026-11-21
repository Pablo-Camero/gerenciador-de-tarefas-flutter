import 'package:firebase_database/firebase_database.dart';
import '../models/usuario.dart';
import '../models/tarefa.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> salvarUsuario(Usuario usuario) async {
    await _database.child('usuarios').child(usuario.uid).set(usuario.toMap());
  }

  Future<Usuario?> buscarUsuario(String uid) async {
    final snapshot = await _database.child('usuarios').child(uid).get();
    if (!snapshot.exists||snapshot.value is! Map) {
      return null;
    }
    return Usuario.fromMap(uid,snapshot.value as Map<dynamic, dynamic>);
  }


  DatabaseReference _tarefasRef(String uid) {
    return _database.child('tarefas').child(uid);
  }

  Future<void> salvarTarefa(String uid, Tarefa tarefa) async {
    await _tarefasRef(uid)
        .child(tarefa.id)
        .set(tarefa.toMap());
  }

  Stream<List<Tarefa>> listarTarefas(String uid) {
    return _tarefasRef(uid).onValue.map((event) {
      final dados = event.snapshot.value;

      if (dados == null || dados is! Map) {
        return <Tarefa>[];
      }

      final tarefas = <Tarefa>[];

      dados.forEach((id, valor) {
        if (valor is Map) {
          tarefas.add(
            Tarefa.fromMap(
              id.toString(),
              valor,
            ),
          );
        }
      });

      tarefas.sort(
        (a, b) => a.dataVencimento.compareTo(b.dataVencimento),
      );

      return tarefas;
    });
  }

  Future<void> atualizarTarefa(String uid, Tarefa tarefa) async {
    await _tarefasRef(uid)
        .child(tarefa.id)
        .update(tarefa.toMap());
  }

  Future<void> excluirTarefa(String uid, String tarefaId) async {
    await _tarefasRef(uid)
        .child(tarefaId)
        .remove();
  }

  String gerarIdTarefa(String uid) {
    return _tarefasRef(uid).push().key!;
  }

  Future<void> excluirDadosUsuario(String uid) async {
    await _database.child('usuarios').child(uid).remove();
    await _database.child('tarefas').child(uid).remove();
  }


}