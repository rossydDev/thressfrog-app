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
      height: 145,
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
    Color mainColor;
    Color bgColor;

    switch (insight.type) {
      case InsightType.buff:
        mainColor = AppColors.neonGreen;
        bgColor = AppColors.neonGreen.withValues(
          alpha: 0.15,
        );
        break;
      case InsightType.curse:
        mainColor = AppColors.errorRed;
        bgColor = AppColors.errorRed.withValues(
          alpha: 0.15,
        );
        break;
      case InsightType.neutral:
      default:
        mainColor = Colors.blueAccent;
        bgColor = Colors.blueAccent.withValues(alpha: 0.15);
        break;
    }

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mainColor.withValues(alpha: 0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [AppColors.surfaceDark, bgColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícone com destaque circular
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  insight.icon,
                  color: mainColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title.toUpperCase(),
                      style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (insight.confidence > 0)
                      Text(
                        "${(insight.confidence * 100).toInt()}% DE CERTEZA",
                        style: TextStyle(
                          color: mainColor.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            insight.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
