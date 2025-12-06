import 'package:flutter/material.dart';

import '../../../core/state/bankroll_controller.dart';
import '../../../core/theme/app_theme.dart';

class HomeStopLossCard extends StatelessWidget {
  const HomeStopLossCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos ListenableBuilder escutando diretamente sua instância Singleton
    return ListenableBuilder(
      listenable: BankrollController.instance,
      builder: (context, child) {
        final controller = BankrollController.instance;

        // 1. Lógica do Ghost Frog
        final bool isGhostActive =
            controller.isGhostModeTriggered;

        // 2. Definição Visual (Cores e Textos)
        final Color themeColor = isGhostActive
            ? AppColors.neonGreen
            : AppColors.errorRed;
        final String statusLabel = isGhostActive
            ? "BLINDADO PELO GHOST FROG 👻"
            : "Limite de Perda (Stop Loss)";
        final IconData icon = isGhostActive
            ? Icons.shield
            : Icons.security;

        // Texto do limite
        final double limitValue = isGhostActive
            ? 0.00
            : controller.stopLossValue;
        final String limitText = isGhostActive
            ? "R\$ 0.00 (Breakeven)"
            : "-R\$ ${limitValue.toStringAsFixed(2)}";

        // 3. Cálculo da Barra
        double progress = 0.0;
        if (isGhostActive) {
          // Se blindado: barra cheia se estiver negativo, vazia se positivo
          progress = controller.profitTodayRaw < 0
              ? 1.0
              : 0.0;
        } else {
          progress = controller.stopLossProgress;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: themeColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: isGhostActive
                ? [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(
                        alpha: 0.1,
                      ),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Icon(icon, color: themeColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.deepBlack,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Valores
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.profitTodayRaw >= 0
                        ? "+R\$ ${controller.profitTodayRaw.toStringAsFixed(2)}"
                        : "-R\$ ${controller.profitTodayRaw.abs().toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    limitText,
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
