import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/insight_model.dart';

class InsightCarousel extends StatelessWidget {
  final List<Insight> insights;

  const InsightCarousel({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140, // Altura do card
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        scrollDirection: Axis.horizontal,
        itemCount: insights.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildInsightCard(insights[index]);
        },
      ),
    );
  }

  Widget _buildInsightCard(Insight insight) {
    // Define as cores baseadas no tipo (Buff, Curse, Neutral)
    Color mainColor;
    Color bgColor;
    IconData defaultIcon;

    switch (insight.type) {
      case InsightType.buff:
        mainColor = AppColors.neonGreen;
        bgColor = AppColors.neonGreen.withValues(
          alpha: 0.1,
        );
        defaultIcon = Icons.arrow_upward;
        break;
      case InsightType.curse:
        mainColor = AppColors.errorRed;
        bgColor = AppColors.errorRed.withValues(alpha: 0.1);
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case InsightType.neutral:
        mainColor = Colors.blueAccent;
        bgColor = Colors.blueAccent.withValues(alpha: 0.1);
        defaultIcon = Icons.info_outline;
        break;
    }

    return Container(
      width:
          280, // Largura fixa para manter padrão no carrossel
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mainColor.withValues(alpha: 0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [AppColors.surfaceDark, bgColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho: Ícone + Título
          Row(
            children: [
              Icon(
                insight.icon,
                color: mainColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title.toUpperCase(),
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (insight.confidence > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${(insight.confidence * 100).toInt()}%",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const Spacer(),

          // Descrição da Profecia
          Text(
            insight.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
