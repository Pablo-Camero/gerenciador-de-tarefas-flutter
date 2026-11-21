
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tarefas_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firebaseService = FirebaseService();
    final usuarioAuth = authService.usuarioAtual;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Usuario?>(
            future: usuarioAuth == null
                ? Future<Usuario?>.value(null)
                : firebaseService.buscarUsuario(usuarioAuth.uid),
            builder: (context, snapshot) {
              final usuario = snapshot.data;
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final corPrimaria = theme.colorScheme.primary;
              final corFundo = isDark
                  ? Color.lerp(corPrimaria, Colors.black, 0.6)!
                  : corPrimaria;
              final corTexto = isDark ? Colors.white : theme.colorScheme.onPrimary;

              return DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(color: corFundo),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        child: Icon(Icons.person, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario?.nome ??
                                  usuarioAuth?.displayName ??
                                  'Usuário',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: corTexto,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              usuario?.email ??
                                  usuarioAuth?.email ??
                                  'Não identificado',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: corTexto.withAlpha(220),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Minhas Tarefas'),
            onTap: () {
              Navigator.pop(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TarefasScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);

              Navigator.pushReplacementNamed(
                context,
                '/configuracoes',
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await authService.logoutUsuario();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
