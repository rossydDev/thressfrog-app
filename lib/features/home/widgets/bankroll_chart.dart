import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/state/bankroll_controller.dart';
import '../../../core/theme/app_theme.dart';

class BankrollChart extends StatelessWidget {
  const BankrollChart({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BankrollController.instance,
      builder: (context, _) {
        final spots = BankrollController.instance.chartData;
        final emoji =
            BankrollController
                .instance
                .userProfile
                ?.animalEmoji ??
            "🐸";

        // 1. BLINDAGEM: Se tiver 0 ou 1 ponto, não desenha gráfico, mostra aviso.
        // Isso evita erros de cálculo de largura e crashes.
        if (spots.length <= 1) {
          return _buildEmptyState();
        }

        // 2. CÁLCULO DE DIMENSÕES (Lógica Responsiva)
        // Pegamos a largura da tela
        final screenWidth = MediaQuery.of(
          context,
        ).size.width;
        // Definimos que cada "Pulo" ocupa 50 pixels de largura
        double chartWidth = spots.length * 50.0;

        // Se a largura calculada for menor que a tela, forçamos ocupar a tela toda
        // (menos o padding de 40px das margens)
        if (chartWidth < screenWidth - 40) {
          chartWidth = screenWidth - 40;
        }

        // 3. CÁLCULOS DE EIXO Y (ALTURA)
        final yValues = spots.map((e) => e.y).toList();
        double minY = yValues.reduce(
          (a, b) => a < b ? a : b,
        );
        double maxY = yValues.reduce(
          (a, b) => a > b ? a : b,
        );

        // Se minY e maxY forem iguais (ex: aposta anulada, saldo não mudou),
        // o gráfico trava. Precisamos dar um "respiro" artificial.
        if (minY == maxY) {
          minY -= 10;
          maxY += 10;
        }

        final buffer = (maxY - minY) * 0.2;

        // 4. ESTRUTURA COM SCROLL
        return SizedBox(
          height: 200, // Altura fixa do container pai
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse:
                true, // Começa mostrando o FINAL (Direita) - Onde o sapo está
            physics:
                const BouncingScrollPhysics(), // Efeito elástico chique
            child: Container(
              width:
                  chartWidth, // Largura dinâmica! Cresce com as apostas
              margin: const EdgeInsets.only(
                top: 24,
                bottom: 10,
              ),
              padding: const EdgeInsets.only(
                right: 32,
                left: 16,
              ), // Espaço pro Sapo não cortar
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    show: false,
                  ),
                  borderData: FlBorderData(show: false),

                  // Limites
                  minY: minY - buffer,
                  maxY: maxY + buffer,
                  minX: spots.first.x,
                  maxX: spots.last.x,

                  // Tooltip
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) =>
                          AppColors.surfaceDark,
                      tooltipBorderRadius: .circular(8),
                      // Ajuste para o tooltip não sair da tela no scroll
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            "R\$ ${spot.y.toStringAsFixed(2)}",
                            const TextStyle(
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.neonGreen,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) =>
                            spot.x == barData.spots.last.x,
                        getDotPainter:
                            (
                              spot,
                              percent,
                              barData,
                              index,
                            ) {
                              return FlDotTextPainter(
                                text: Text(
                                  emoji,
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                offset: const Offset(
                                  0,
                                  -20,
                                ),
                              );
                            },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.neonGreen.withValues(
                              alpha: 0.2,
                            ),
                            AppColors.neonGreen.withValues(
                              alpha: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            color: AppColors.textGrey.withValues(alpha: .3),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            "Faça mais pulos para ver sua evolução!",
            style: TextStyle(
              color: AppColors.textGrey.withValues(
                alpha: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A Classe Painter continua igual, necessária para desenhar o texto
class FlDotTextPainter extends FlDotPainter {
  final Text text;
  final Offset offset;

  FlDotTextPainter({
    required this.text,
    this.offset = Offset.zero,
  });

  @override
  void draw(
    Canvas canvas,
    FlSpot spot,
    Offset offsetInCanvas,
  ) {
    final textSpan = TextSpan(
      text: text.data,
      style: text.style,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    final x =
        offsetInCanvas.dx -
        (textPainter.width / 2) +
        offset.dx;
    final y =
        offsetInCanvas.dy -
        (textPainter.height / 2) +
        offset.dy;
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  Size getSize(FlSpot spot) => const Size(32, 32);

  @override
  FlDotPainter lerp(
    FlDotPainter a,
    FlDotPainter b,
    double t,
  ) => this;

  @override
  Color get mainColor => Colors.transparent;

  @override
  List<Object?> get props => [text, offset];
}
