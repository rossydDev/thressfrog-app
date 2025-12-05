import 'package:flutter/material.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CABEÇALHO DO PERFIL
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
                                  .withOpacity(0.2),
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

                // 2. PAINEL DE THRESHOLDS (METAS DO DIA)
                const Text(
                  "Metas do Dia",
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                _buildThresholdCard(
                  title: "Meta de Lucro (Stop Win)",
                  current: controller.profitTodayRaw > 0
                      ? controller.profitTodayRaw
                      : 0,
                  target: controller.stopWinValue,
                  progress: controller.stopWinProgress,
                  color: AppColors.neonGreen,
                  icon: Icons.rocket_launch,
                ),

                const SizedBox(height: 12),

                _buildThresholdCard(
                  title: "Limite de Perda (Stop Loss)",
                  current: controller.profitTodayRaw < 0
                      ? controller.profitTodayRaw.abs()
                      : 0, // Mostra positivo para a barra
                  target: controller.stopLossValue,
                  progress: controller.stopLossProgress,
                  color: AppColors.errorRed,
                  icon: Icons.shield,
                  isLoss: true,
                ),

                const SizedBox(height: 40),

                // 3. BADGES (CONQUISTAS)
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
                      unlocked: controller.bets.isNotEmpty,
                    ),
                    _buildBadge(
                      icon: Icons.emoji_events,
                      name: "Vencedor",
                      unlocked: controller.bets.any(
                        (b) => b.isGreen,
                      ),
                    ),
                    _buildBadge(
                      icon: Icons.local_fire_department,
                      name: "Sniper",
                      unlocked:
                          _calculateWinRate(controller) >=
                          60.0, // Ex: WR > 60%
                    ),
                    _buildBadge(
                      icon: Icons.diamond,
                      name: "Sapo Rico",
                      unlocked:
                          controller.currentBalance >=
                          1000.0,
                    ),
                    _buildBadge(
                      icon: Icons.school,
                      name: "Estudioso",
                      unlocked:
                          controller.bets.length >= 10,
                    ),
                    _buildBadge(
                      icon: Icons.balance,
                      name: "Disciplina",
                      unlocked: user.currentLevel >= 5,
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

  // Lógica simples para calcular WinRate numérico
  double _calculateWinRate(BankrollController controller) {
    if (controller.bets.isEmpty) return 0.0;
    final finished = controller.bets
        .where(
          (b) => ![
            'pending',
            'voided',
          ].contains(b.result.name),
        )
        .length;
    if (finished == 0) return 0.0;
    final wins = controller.bets
        .where((b) => b.isGreen)
        .length;
    return (wins / finished) * 100;
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
        border: Border.all(color: color.withOpacity(0.3)),
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
                style: TextStyle(
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
                ? AppColors.neonGreen.withOpacity(0.1)
                : AppColors.surfaceDark,
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked
                  ? AppColors.neonGreen
                  : AppColors.textGrey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked
                ? AppColors.neonGreen
                : AppColors.textGrey.withOpacity(0.3),
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
                : AppColors.textGrey.withOpacity(0.5),
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
