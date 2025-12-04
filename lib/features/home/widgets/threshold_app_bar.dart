import 'package:flutter/material.dart';

import '../../../core/state/bankroll_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/settings_page.dart';

class ThresholdAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ThresholdAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BankrollController.instance,
      builder: (context, _) {
        final controller = BankrollController.instance;
        final user = controller.userProfile;

        // Dados de Gamificação
        final level = user?.currentLevel ?? 1;
        final xpProgress = user?.progressToLevelUp ?? 0.0;
        final xpText =
            "${user?.currentXP.toInt()}/${user?.xpToNextLevel.toInt()} XP";

        return AppBar(
          toolbarHeight: 80,
          backgroundColor: AppColors.deepBlack,
          titleSpacing: 0,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. AVATAR E NÍVEL (Esquerda)
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonGreen,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user?.animalEmoji ?? "🐸",
                          style: const TextStyle(
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),
                    // Badge do Nível
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$level",
                        style: const TextStyle(
                          color: AppColors.deepBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // 2. BARRA DE XP E NOME (Centro Expandido)
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user?.name ?? 'Invocador',
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            xpText,
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Barra de XP
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: xpProgress == 0
                              ? 0.0
                              : xpProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen,
                              borderRadius:
                                  BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonGreen
                                      .withValues(
                                        alpha: 0.5,
                                      ),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 3. BOTÃO CONFIG (Direita)
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.textGrey,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
