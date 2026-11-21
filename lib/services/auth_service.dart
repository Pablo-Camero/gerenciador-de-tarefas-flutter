import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> cadastrarUsuario({
    required String email,
    required String senha,
  }) async {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
  }

  Future<UserCredential> loginUsuario({
    required String email,
    required String senha,
  }) async {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
  }

  Future<void> logoutUsuario() async {
    await _auth.signOut();
  }

  User? get usuarioAtual => _auth.currentUser;

  Future<void> excluirConta() async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    await usuario.delete();
  }


}