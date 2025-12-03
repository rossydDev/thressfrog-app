import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import do Hive

import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';
import 'models/bet_model.dart'; // Import para registrar os Adapters

void main() async {
  // Garante que o motor do Flutter tá pronto
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive no celular
  await Hive.initFlutter();

  // Registra os "tradutores" que o comando da Etapa 3 criou
  Hive.registerAdapter(BetResultAdapter());
  Hive.registerAdapter(BetAdapter());

  // Abre as caixas (Tabelas)
  // Box 'settings': para saldo
  await Hive.openBox('settings');
  // Box 'bets': para a lista de apostas
  await Hive.openBox<Bet>('bets');

  runApp(const ThressFrogApp());
}

class ThressFrogApp extends StatelessWidget {
  const ThressFrogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThressFrog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
