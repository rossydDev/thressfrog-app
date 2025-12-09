import 'package:fl_chart/fl_chart.dart'; // Para gráfico de pizza se quiser
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/league_stats_model.dart';

class LeagueDetailPage extends StatelessWidget {
  final LeagueStats stats;

  const LeagueDetailPage({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(stats.leagueName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // LOGO GRANDE
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceDark,
                  border: Border.all(
                    color: AppColors.neonPurple,
                    width: 2,
                  ),
                  image: stats.leagueLogo.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            stats.leagueLogo,
                          ),
                        )
                      : null,
                ),
                child: stats.leagueLogo.isEmpty
                    ? const Icon(
                        Icons.emoji_events,
                        size: 40,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 30),

            // CARD DE ESTATÍSTICA PRINCIPAL (Side Bias)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Controle de Mapa (Side Bias)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // GRÁFICO DE PIZZA (Representação visual)
                  SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value:
                                stats.blueSideWinRate * 100,
                            color: Colors.blueAccent,
                            title:
                                "${(stats.blueSideWinRate * 100).round()}%",
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value:
                                stats.redSideWinRate * 100,
                            color: Colors.redAccent,
                            title:
                                "${(stats.redSideWinRate * 100).round()}%",
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "O Lado Azul tem historicamente vantagem de First Pick e controle de Dragão.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // OUTROS DADOS (Lista)
            _buildStatRow(
              "Duração Média",
              "${stats.avgMatchDuration.inMinutes} minutos",
              Icons.timer,
            ),
            _buildStatRow(
              "Jogos Analisados",
              "${stats.totalGamesAnalyzed}",
              Icons.analytics,
            ),

            const SizedBox(height: 40),

            // Placeholder para Futuro
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.construction,
                    color: AppColors.textGrey,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Top Picks & Bans em breve...",
                      style: TextStyle(
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonPurple),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
