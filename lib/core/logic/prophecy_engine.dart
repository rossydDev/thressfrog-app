import 'package:flutter/material.dart';

import '../../models/bet_model.dart';
import '../../models/insight_model.dart';

class ProphecyEngine {
  /// Analisa as apostas e gera uma lista de Insights
  static List<Insight> generateInsights(
    List<Bet> bets, {
    int? filterTeamId,
  }) {
    final List<Insight> insights = [];

    // 1. Filtra as apostas relevantes (Finalizadas + Filtro de Time + Com dados do Grimório)
    final validBets = bets.where((b) {
      final isFinished =
          b.result == BetResult.win ||
          b.result == BetResult.loss;
      final matchTeam =
          filterTeamId == null ||
          b.pickedTeamId == filterTeamId;
      final hasGrimoireData =
          b.myTeamDraft !=
          null; // Garante que tem dados táticos
      return isFinished && matchTeam && hasGrimoireData;
    }).toList();

    if (validBets.length < 3) {
      return [
        Insight(
          title: "Grimório Vazio",
          description:
              "Registre mais 3 jogos no Modo Grimório para liberar profecias.",
          type: InsightType.neutral,
          icon: Icons.auto_stories,
          confidence: 0.0,
        ),
      ];
    }

    // --- ANÁLISE 1: A MALDIÇÃO DOS DRAGÕES ---
    // Verifica se poucos dragões causam derrota
    _analyzeLowDragons(validBets, insights);

    // --- ANÁLISE 2: O BUFF DAS TORRES ---
    // Verifica se muitas torres garantem vitória
    _analyzeHighTowers(validBets, insights);

    // --- ANÁLISE 3: ZONA DE PERIGO (KILLS) ---
    // Verifica se jogos sangrentos (muitas kills) são bons ou ruins
    _analyzeHighKills(validBets, insights);

    // Ordena por relevância (Confiança)
    insights.sort(
      (a, b) => b.confidence.compareTo(a.confidence),
    );

    return insights;
  }

  // Lógica: Se dragões < 2, qual a taxa de derrota?
  static void _analyzeLowDragons(
    List<Bet> bets,
    List<Insight> insights,
  ) {
    int lowDragonGames = 0;
    int losses = 0;

    for (var bet in bets) {
      if (bet.dragons != null && bet.dragons! <= 1) {
        // 0 ou 1 dragão
        lowDragonGames++;
        if (bet.result == BetResult.loss) losses++;
      }
    }

    if (lowDragonGames >= 3) {
      final lossRate = losses / lowDragonGames;
      // Se perder mais de 70% das vezes com pouco dragão
      if (lossRate >= 0.70) {
        insights.add(
          Insight(
            title: "A Maldição do Rio",
            description:
                "Sem controle? Você perdeu ${(lossRate * 100).toInt()}% dos jogos com menos de 2 Dragões.",
            type: InsightType.curse,
            icon: Icons.water_drop, // Ícone de água/dragão
            confidence: lossRate,
          ),
        );
      }
    }
  }

  // Lógica: Se torres >= 8, qual a taxa de vitória?
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
            title: "Demolição Imparável",
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

  // Lógica: Jogos com muitas kills (Over) dão lucro?
  static void _analyzeHighKills(
    List<Bet> bets,
    List<Insight> insights,
  ) {
    int bloodyGames = 0;
    int wins = 0;
    // Define "Muitas Kills" como > 30 (média do LoL competitivo é ~26)
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
            title: "Caos Favorável",
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
            title: "Sangria Descontrolada",
            description:
                "Cuidado com o Over. Você perdeu ${((1 - winRate) * 100).toInt()}% dos jogos sangrentos (+$killThreshold Kills).",
            type: InsightType.curse,
            icon: Icons.bloodtype,
            confidence: (1 - winRate),
          ),
        );
      }
    }
  }
}
