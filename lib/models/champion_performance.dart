class ChampionPerformance {
  final String championId; // Ex: "Ahri"
  final int totalGames;
  final int wins;
  final double netProfit;

  ChampionPerformance({
    required this.championId,
    required this.totalGames,
    required this.wins,
    required this.netProfit,
  });

  double get winRate =>
      totalGames > 0 ? wins / totalGames : 0.0;

  // Retorna "80%" formatado
  String get winRateLabel =>
      "${(winRate * 100).toStringAsFixed(0)}%";
}

class ObjectiveStats {
  final double avgTowersWin;
  final double avgTowersLoss;
  final double avgDragonsWin;
  final double avgDragonsLoss;
  final double avgKills; // Média geral para Over/Under
  final double avgDuration; // Média geral de tempo

  ObjectiveStats({
    required this.avgTowersWin,
    required this.avgTowersLoss,
    required this.avgDragonsWin,
    required this.avgDragonsLoss,
    required this.avgKills,
    required this.avgDuration,
  });
}
