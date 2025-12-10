import 'package:flutter/material.dart';

import '../../models/bet_model.dart';
import '../../models/insight_model.dart';

class ProphecyEngine {
  /// Gera a lista de insights. Retorna vazio [] se não houver dados suficientes (bloqueado).
  static List<Insight> generateInsights(
    List<Bet> bets, {
    int? filterTeamId,
  }) {
    final List<Insight> insights = [];

    // Filtra apostas válidas (Finalizadas + Com dados do Grimório)
    final validBets = bets.where((b) {
      final isFinished =
          b.result == BetResult.win ||
          b.result == BetResult.loss;
      // Se houver filtro de time, aplica. Se não, considera todas (global).
      final matchTeam =
          filterTeamId == null ||
          b.pickedTeamId == filterTeamId;
      final hasGrimoireData = b.myTeamDraft != null;
      return isFinished && matchTeam && hasGrimoireData;
    }).toList();

    // [LÓGICA DE BLOQUEIO]
    // Se tiver menos de 3 jogos válidos, retornamos vazio para a UI mostrar o "Livro Trancado".
    if (validBets.length < 3) {
      return [];
    }

    // --- ANÁLISE DOS DADOS ---
    _analyzeLowDragons(validBets, insights);
    _analyzeHighTowers(validBets, insights);
    _analyzeHighKills(validBets, insights);

    // Ordena por confiança (maior % primeiro)
    insights.sort(
      (a, b) => b.confidence.compareTo(a.confidence),
    );

    return insights;
  }

  /// Helper para a UI saber quantos jogos faltam para desbloquear
  static int countValidGames(List<Bet> bets) {
    return bets
        .where(
          (b) =>
              (b.result == BetResult.win ||
                  b.result == BetResult.loss) &&
              b.myTeamDraft != null,
        )
        .length;
  }

  // --- REGRAS DE ANÁLISE ---

  static void _analyzeLowDragons(
    List<Bet> bets,
    List<Insight> insights,
  ) {
    int lowDragonGames = 0;
    int losses = 0;

    for (var bet in bets) {
      if (bet.dragons != null && bet.dragons! <= 1) {
        lowDragonGames++;
        if (bet.result == BetResult.loss) losses++;
      }
    }

    if (lowDragonGames >= 3) {
      final lossRate = losses / lowDragonGames;
      if (lossRate >= 0.70) {
        insights.add(
          Insight(
            title: "A MALDIÇÃO DO RIO",
            description:
                "Você perdeu ${(lossRate * 100).toInt()}% dos jogos com menos de 2 Dragões. Priorize objetivos!",
            type: InsightType.curse,
            icon: Icons.water_drop,
            confidence: lossRate,
          ),
        );
      }
    }
  }

  static void _analyzeHighTowers(
    List<Bet> bets,
    List<Insight> insights,
  ) {
    int highTowerGames = 0;
    int wins = 0;

    for (var bet in bets) {
      if (bet.towers != null && bet.towers! >= 8) {
        highTowerGames++;
        if (bet.result == BetResult.win) wins++;
      }
    }

    if (highTowerGames >= 3) {
      final winRate = wins / highTowerGames;
      if (winRate >= 0.80) {
        insights.add(
          Insight(
            title: "DEMOLIÇÃO IMPARÁVEL",
            description:
                "Quebra tudo! ${(winRate * 100).toInt()}% de vitória ao levar 8+ Torres.",
            type: InsightType.buff,
            icon: Icons.castle,
            confidence: winRate,
          ),
        );
      }
    }
  }

  static void _analyzeHighKills(
    List<Bet> bets,
    List<Insight> insights,
  ) {
    int bloodyGames = 0;
    int wins = 0;
    const killThreshold = 30;

    for (var bet in bets) {
      if (bet.totalMatchKills != null &&
          bet.totalMatchKills! >= killThreshold) {
        bloodyGames++;
        if (bet.result == BetResult.win) wins++;
      }
    }

    if (bloodyGames >= 3) {
      final winRate = wins / bloodyGames;

      if (winRate >= 0.75) {
        insights.add(
          Insight(
            title: "CAOS FAVORÁVEL",
            description:
                "Você lucra no caos. ${(winRate * 100).toInt()}% de vitória em jogos com +$killThreshold Kills.",
            type: InsightType.buff,
            icon: Icons.local_fire_department,
            confidence: winRate,
          ),
        );
      } else if (winRate <= 0.30) {
        insights.add(
          Insight(
            title: "SANGRIA DESCONTROLADA",
            description:
                "Cuidado com o Over. Você perdeu ${((1 - winRate) * 100).toInt()}% dos jogos sangrentos.",
            type: InsightType.curse,
            icon: Icons.bloodtype,
            confidence: (1 - winRate),
          ),
        );
      }
    }
  }
}
