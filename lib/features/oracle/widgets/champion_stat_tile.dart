import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/champion_performance.dart';

class ChampionStatTile extends StatelessWidget {
  final ChampionPerformance performance;
  final int index;
  final VoidCallback?
  onTap; // Para abrir detalhes no futuro

  const ChampionStatTile({
    super.key,
    required this.performance,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = performance.netProfit >= 0;
    final profitColor = isProfit
        ? AppColors.neonGreen
        : AppColors.errorRed;

    // Gradiente sutil baseado no lucro
    final bgGradient = LinearGradient(
      colors: isProfit
          ? [
              AppColors.surfaceDark,
              AppColors.neonGreen.withValues(alpha: 0.05),
            ]
          : [
              AppColors.surfaceDark,
              AppColors.errorRed.withValues(alpha: 0.05),
            ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final imageUrl =
        'https://ddragon.leagueoflegends.com/cdn/14.23.1/img/champion/${performance.championId}.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: bgGradient,
        border: Border.all(
          color: profitColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 1. Ranking e Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: profitColor,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Badge de Ranking
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white10,
                        ),
                      ),
                      child: Text(
                        "#${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // 2. Informações Principais
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        performance.championId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildMiniBadge(
                            "${performance.wins}V - ${(performance.totalGames - performance.wins)}D",
                            Colors.white24,
                          ),
                          const SizedBox(width: 8),
                          _buildMiniBadge(
                            "${performance.totalGames} Jogos",
                            Colors.blueAccent.withValues(
                              alpha: 0.2,
                            ),
                            textColor: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Métricas de Sucesso
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      performance.winRateLabel,
                      style: TextStyle(
                        color: profitColor,
                        fontWeight:
                            FontWeight.w900, // Extra Bold
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "${isProfit ? '+' : ''}R\$ ${performance.netProfit.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: profitColor.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(
    String text,
    Color bgColor, {
    Color textColor = Colors.white70,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
