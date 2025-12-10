import 'package:flutter/material.dart';

enum InsightType {
  buff, // Coisa boa (Verde/Dourado)
  curse, // Coisa ruim/Alerta (Vermelho/Roxo)
  neutral, // Curiosidade (Azul)
}

class Insight {
  final String title;
  final String description;
  final InsightType type;
  final IconData icon;
  final double
  confidence; // O quanto esse dado é forte (Ex: 90% de winrate)

  Insight({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.confidence,
  });
}
