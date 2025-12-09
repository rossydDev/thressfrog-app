import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/champion_performance.dart';

class ChampionStatTile extends StatelessWidget {
  final ChampionPerformance performance;
  final int index; // Para criar um ranking (1º, 2º...)

  const ChampionStatTile({
    super.key,
    required this.performance,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = performance.netProfit >= 0;
    final color = isProfit
        ? AppColors.neonGreen
        : AppColors.errorRed;

    // URL da imagem (Usando uma versão recente fixa para simplificar o carregamento visual)
    final imageUrl =
        'https://ddragon.leagueoflegends.com/cdn/14.23.1/img/champion/${performance.championId}.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // 1. Ranking
          Text(
            "#${index + 1}",
            style: const TextStyle(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),

          // 2. Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 3. Nome e Winrate
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performance.championId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${performance.wins}V / ${(performance.totalGames - performance.wins)}D (${performance.winRateLabel})",
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 4. Lucro Financeiro
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isProfit ? "LUCRO" : "PREJUÍZO",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${isProfit ? '+' : ''}R\$ ${performance.netProfit.toStringAsFixed(2)}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
