import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class GrimoireLockedCard extends StatelessWidget {
  final int currentGames;
  final int requiredGames;

  const GrimoireLockedCard({
    super.key,
    required this.currentGames,
    this.requiredGames = 3,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentGames / requiredGames).clamp(
      0.0,
      1.0,
    );
    final gamesLeft = requiredGames - currentGames;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceDark,
            AppColors.neonPurple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Ícone do Livro Trancado (Grande)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.lock,
              color: Colors.white24,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),

          // Texto e Progresso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PROFECIAS OCULTAS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Registre mais $gamesLeft jogos no Modo Grimório para destrancar a sabedoria do sapo.",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                // Barra de Progresso
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black,
                    color: AppColors.neonPurple,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
