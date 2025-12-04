import 'package:flutter/material.dart';

import '../../../core/state/bankroll_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/settings_page.dart';

class ThresholdAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ThresholdAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80); // Mais alto que o padrão

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BankrollController.instance,
      builder: (context, _) {
        final controller = BankrollController.instance;
        final user = controller.userProfile;

        final lossProgress = controller.stopLossProgress;
        final winProgress = controller.stopWinProgress;

        return AppBar(
          toolbarHeight: 80,
          backgroundColor: AppColors.deepBlack,
          titleSpacing: 0,
          elevation: 0,
          automaticallyImplyLeading:
              false, // Remove seta de voltar padrão
          title: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Linha 1: Identidade e Botão Config
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          user?.animalEmoji ?? "🐸",
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Olá, ${user?.name ?? 'Invocador'}",
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
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

                const SizedBox(height: 8),

                // Linha 2: As Barras de Threshold (Visual Gamer)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fundo do trilho
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(
                          3,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        // Lado ESQUERDO (Prejuízo/Stop Loss)
                        Expanded(
                          child: Align(
                            alignment:
                                Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: lossProgress == 0
                                  ? 0.0
                                  : lossProgress,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed,
                                  borderRadius:
                                      const BorderRadius.horizontal(
                                        left:
                                            Radius.circular(
                                              3,
                                            ),
                                      ),
                                  boxShadow: [
                                    if (lossProgress > 0.8)
                                      BoxShadow(
                                        color: AppColors
                                            .errorRed
                                            .withValues(
                                              alpha: 0.6,
                                            ),
                                        blurRadius: 6,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Divisor Central (Zero)
                        Container(
                          width: 2,
                          height: 10,
                          color: AppColors.textWhite,
                        ),

                        // Lado DIREITO (Lucro/Stop Win)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: winProgress == 0
                                  ? 0.0
                                  : winProgress,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.neonGreen,
                                  borderRadius:
                                      const BorderRadius.horizontal(
                                        right:
                                            Radius.circular(
                                              3,
                                            ),
                                      ),
                                  boxShadow: [
                                    if (winProgress >= 1.0)
                                      BoxShadow(
                                        color: AppColors
                                            .neonGreen
                                            .withValues(
                                              alpha: 0.6,
                                            ),
                                        blurRadius: 6,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Linha 3: Textos de Status
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      // Valor do Stop Loss em R$
                      Text(
                        "-R\$${(controller.stopLossValue).toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 10,
                        ),
                      ),

                      // Status Central
                      Text(
                        controller.isStopLossHit
                            ? "STOP LOSS!"
                            : (controller.isStopWinHit
                                  ? "META BATIDA!"
                                  : "EM JOGO"),
                        style: TextStyle(
                          color: controller.isStopLossHit
                              ? AppColors.errorRed
                              : (controller.isStopWinHit
                                    ? AppColors.neonGreen
                                    : AppColors.textGrey),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),

                      // Valor do Stop Win em R$
                      Text(
                        "+R\$${(controller.stopWinValue).toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
