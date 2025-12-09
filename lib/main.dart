import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/champion_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'models/bet_model.dart';
import 'models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Registrar Adapters (Na ordem dos TypeIDs)
  Hive.registerAdapter(BetResultAdapter()); // ID 0
  Hive.registerAdapter(BetAdapter()); // ID 1
  Hive.registerAdapter(InvestorProfileAdapter()); // ID 2
  Hive.registerAdapter(UserProfileAdapter()); // ID 3
  Hive.registerAdapter(LoLSideAdapter());

  ChampionService().getChampions();

  // Abrir caixas
  await Hive.openBox('settings');
  await Hive.openBox<Bet>('bets');
  runApp(const ThressFrogApp());
}

class ThressFrogApp extends StatelessWidget {
  const ThressFrogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lógica do Porteiro:
    // Verifica se já existe um 'user_profile' salvo na caixa de settings
    final settingsBox = Hive.box('settings');
    final hasUser = settingsBox.containsKey('user_profile');

    return MaterialApp(
      title: 'ThressFrog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Se tem usuário -> Home. Se não tem -> Onboarding.
      home: hasUser
          ? const HomePage()
          : const OnboardingPage(),
    );
  }
}
