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

  // --- REGISTRO DOS ADAPTERS (Organizado por IDs) ---
  // ID 1: Bet
  Hive.registerAdapter(BetAdapter());

  // ID 2: BetResult
  Hive.registerAdapter(BetResultAdapter());

  // ID 3: UserProfile
  Hive.registerAdapter(UserProfileAdapter());

  // ID 4: LoLSide
  Hive.registerAdapter(LoLSideAdapter());

  // ID 5: InvestorProfile (Novo ID!)
  Hive.registerAdapter(InvestorProfileAdapter());

  // Carrega os campeões em segundo plano
  ChampionService().getChampions();

  // Abre as caixas
  await Hive.openBox('settings');
  await Hive.openBox<Bet>('bets');

  runApp(const ThressFrogApp());
}

class ThressFrogApp extends StatelessWidget {
  const ThressFrogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    // Verifica se já tem perfil criado
    final hasUser = settingsBox.containsKey('user_profile');

    return MaterialApp(
      title: 'ThressFrog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: hasUser
          ? const HomePage()
          : const OnboardingPage(),
    );
  }
}
