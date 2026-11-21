
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/configuracoes_screen.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PreferencesService _preferencesService =
      PreferencesService();

  bool _temaEscuro = false;
  bool _carregandoTema = true;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  Future<void> _carregarTema() async {
    try {
      final temaSalvo =
          await _preferencesService.carregarTema();

      if (!mounted) return;

      setState(() {
        _temaEscuro = temaSalvo;
        _carregandoTema = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar tema: $e');

      if (!mounted) return;

      setState(() {
        _carregandoTema = false;
      });
    }
  }

  Future<void> _alterarTema(bool valor) async {
    await _preferencesService.salvarTema(valor);

    if (!mounted) return;

    setState(() {
      _temaEscuro = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoTema) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Gerenciador de Tarefas',
      theme: AppTheme.temaClaro,
      darkTheme: AppTheme.temaEscuro,

      themeMode: _temaEscuro
          ? ThemeMode.dark
          : ThemeMode.light,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),

      routes: {
        '/configuracoes': (context) => ConfiguracoesScreen(
          temaEscuro: _temaEscuro,
          onTemaAlterado: _alterarTema,
        ),
      },
    );
  }
}
