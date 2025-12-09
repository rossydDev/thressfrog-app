import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/league_stats_model.dart';

class LeagueCard extends StatelessWidget {
  final LeagueStats stats;
  final VoidCallback onTap;

  const LeagueCard({
    super.key,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula a porcentagem para a barra de duelo
    final bluePct = stats.blueSideWinRate;
    // final redPct = stats.redSideWinRate; (Implícito no resto da barra)

    return Container(
      width: 300, // Card mais largo para caber informações
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          overlayColor: WidgetStateProperty.all(
            AppColors.neonPurple.withValues(alpha: 0.1),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Fundo com degradê sutil
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceDark,
                  Color(0xFF1E1E1E),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.5,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                // 1. CABEÇALHO (Logo e Nome)
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        image: stats.leagueLogo.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  stats.leagueLogo,
                                ),
                                fit: BoxFit.contain,
                              )
                            : null,
                      ),
                      child: stats.leagueLogo.isEmpty
                          ? const Icon(
                              Icons.emoji_events,
                              color: AppColors.neonPurple,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats.leagueName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${stats.totalGamesAnalyzed} partidas analisadas",
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 2. BARRA DE DUELO (Blue vs Red)
                Column(
                  children: [
                    // Textos de Porcentagem
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "BLUE ${(stats.blueSideWinRate * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${(stats.redSideWinRate * 100).toStringAsFixed(0)}% RED",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // A Barra Visual
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(
                          alpha: 0.2,
                        ), // Fundo base (Red)
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Parte Azul (Flexível)
                          Flexible(
                            flex: (bluePct * 100).toInt(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius:
                                    BorderRadius.circular(
                                      4,
                                    ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent
                                        .withValues(
                                          alpha: 0.5,
                                        ),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Espaço vazio que revela o fundo (Red)
                          Flexible(
                            flex: ((1 - bluePct) * 100)
                                .toInt(),
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 3. RODAPÉ (Duração e Badge)
                Row(
                  children: [
                    _buildChip(
                      icon: Icons.timer,
                      label:
                          "${stats.avgMatchDuration.inMinutes} min",
                      color: AppColors.neonPurple,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white24,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
