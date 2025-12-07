class LeagueStats {
  final String leagueName;
  final String leagueLogo;
  final int totalGamesAnalyzed;
  final double blueSideWinRate;
  final double redSideWinRate;
  final Duration avgMatchDuration;

  LeagueStats({
    required this.leagueName,
    required this.leagueLogo,
    required this.totalGamesAnalyzed,
    required this.blueSideWinRate,
    required this.redSideWinRate,
    required this.avgMatchDuration,
  });

  bool get blueSideAdvantage =>
      blueSideWinRate > redSideWinRate;
}
