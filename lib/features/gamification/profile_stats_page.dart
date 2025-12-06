import 'package:flutter/material.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/home_stop_loss_card.dart'; // Certifique-se que o caminho está certo

class ProfileStatsPage extends StatelessWidget {
  const ProfileStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PERFIL DO INVOCADOR"),
      ),
      body: ListenableBuilder(
        listenable: BankrollController.instance,
        builder: (context, _) {
          final controller = BankrollController.instance;
          final user = controller.userProfile;

          if (user == null) return const SizedBox();

          // CÁLCULOS PARA O STOP WIN (Que estava faltando)
          final profit = controller.profitTodayRaw;
          final stopWin = controller.stopWinValue;
          final stopWinProgress = (profit > 0)
              ? (profit / stopWin).clamp(0.0, 1.0)
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CABEÇALHO (MANTIDO)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neonGreen,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonGreen
                                  .withValues(alpha: .2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.animalEmoji,
                            style: const TextStyle(
                              fontSize: 50,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Nível ${user.currentLevel} • ${user.profile.name}",
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 2. PAINEL DE THRESHOLDS
                const Text(
                  "Metas do Dia",
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                // CARD STOP WIN (Recuperado)
                _buildThresholdCard(
                  title: "Meta de Lucro (Stop Win)",
                  current: profit > 0
                      ? profit
                      : 0, // Só mostra valor se for positivo
                  target: stopWin,
                  progress:
                      stopWinProgress, // Variável calculada no início do build
                  color: AppColors.neonGreen,
                  icon: Icons.rocket_launch,
                ),

                const SizedBox(
                  height: 16,
                ), // Espaço entre os cards
                // CARD STOP LOSS (O Novo Widget)
                const HomeStopLossCard(),

                const SizedBox(height: 40),

                // 3. BADGES (MANTIDO)
                const Text(
                  "Sala de Troféus",
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildBadge(
                      icon: Icons.flag,
                      name: "Primeiro Pulo",
                      unlocked: user.achivements.contains(
                        'first_bet',
                      ),
                    ),
                    _buildBadge(
                      icon: Icons.emoji_events,
                      name: "Vencedor",
                      unlocked: user.achivements.contains(
                        'winner',
                      ),
                    ),
                    _buildBadge(
                      icon: Icons.local_fire_department,
                      name: "Sniper",
                      unlocked: user.achivements.contains(
                        'sniper',
                      ),
                    ),
                    _buildBadge(
                      icon: Icons.diamond,
                      name: "Sapo Rico",
                      unlocked: user.achivements.contains(
                        'rich_frog',
                      ),
                    ),
                    _buildBadge(
                      icon: Icons.school,
                      name: "Estudioso",
                      unlocked: user.achivements.contains(
                        'scholar',
                      ),
                    ),
                    _buildBadge(
                      icon: Icons.balance,
                      name: "Disciplina",
                      unlocked: user.achivements.contains(
                        'discipline',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThresholdCard({
    required String title,
    required double current,
    required double target,
    required double progress,
    required Color color,
    required IconData icon,
    bool isLoss = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: .3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.deepBlack,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${isLoss ? '-' : '+'}R\$ ${current.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
              Text(
                "${isLoss ? '-' : '+'}R\$ ${target.toStringAsFixed(2)}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String name,
    required bool unlocked,
  }) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: unlocked
                ? AppColors.neonGreen.withValues(alpha: .1)
                : AppColors.surfaceDark,
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked
                  ? AppColors.neonGreen
                  : AppColors.textGrey.withValues(
                      alpha: .3,
                    ),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked
                ? AppColors.neonGreen
                : AppColors.textGrey.withValues(alpha: .3),
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: unlocked
                ? AppColors.textWhite
                : AppColors.textGrey.withValues(alpha: .5),
            fontSize: 12,
            fontWeight: unlocked
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
