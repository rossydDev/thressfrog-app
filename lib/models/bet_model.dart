import 'package:hive/hive.dart';

part 'bet_model.g.dart';

@HiveType(typeId: 2)
enum BetResult {
  @HiveField(0)
  pending,
  @HiveField(1)
  win,
  @HiveField(2)
  loss,
  @HiveField(3)
  voided,
}

@HiveType(typeId: 4)
enum LoLSide {
  @HiveField(0)
  blue,
  @HiveField(1)
  red,
}

@HiveType(typeId: 1)
class Bet extends HiveObject {
  // --- CAMPOS BÁSICOS ---
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String matchTitle;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final double stake;
  @HiveField(4)
  final double odd;
  @HiveField(5)
  final BetResult result;
  @HiveField(6)
  final String notes;

  // --- DADOS API (V1.0) ---
  @HiveField(7)
  final int? pandaMatchId;
  @HiveField(8)
  final int? pickedTeamId;
  @HiveField(9)
  final int? gameNumber;
  @HiveField(10)
  final LoLSide? side;

  // --- DADOS DO GRIMÓRIO (TÁTICOS V2.0) ---

  // Preenchidos na CRIAÇÃO
  @HiveField(11)
  final List<String>? myTeamDraft; // Campeões do seu time

  @HiveField(17)
  final List<String>? enemyTeamDraft; // [NOVO] Campeões inimigos

  // Preenchidos na RESOLUÇÃO (Pós-Jogo)
  @HiveField(12)
  final int? towers;

  @HiveField(13)
  final int? dragons;

  @HiveField(14)
  final int? totalMatchKills; // Total de abates do seu time

  @HiveField(15)
  final int? baronNashors;

  @HiveField(16)
  final int? matchDuration;
  @HiveField(18)
  final String? pickedTeamName;
  @HiveField(19)
  final String? pickedTeamLogo;

  Bet({
    required this.id,
    required this.matchTitle,
    required this.date,
    required this.stake,
    required this.odd,
    required this.result,
    this.notes = '',
    this.pandaMatchId,
    this.pickedTeamId,
    this.gameNumber,
    this.side,
    this.myTeamDraft,
    this.enemyTeamDraft,
    this.towers,
    this.dragons,
    this.totalMatchKills,
    this.baronNashors,
    this.matchDuration,
    this.pickedTeamLogo,
    this.pickedTeamName,
  });

  // Getters auxiliares
  double get profit =>
      result == BetResult.win ? (stake * odd) - stake : 0.0;

  double get netImpact {
    if (result == BetResult.win) return profit;
    if (result == BetResult.loss) return -stake;
    return 0.0;
  }

  bool get isGreen => result == BetResult.win;
  bool get isRed => result == BetResult.loss;

  // CopyWith atualizado com todos os campos novos
  Bet copyWith({
    String? id,
    String? matchTitle,
    DateTime? date,
    double? stake,
    double? odd,
    BetResult? result,
    String? notes,
    int? pandaMatchId,
    int? pickedTeamId,
    int? gameNumber,
    LoLSide? side,
    List<String>? myTeamDraft,
    List<String>? enemyTeamDraft,
    int? towers,
    int? dragons,
    int? totalMatchKills,
    int? baronNashors,
    int? matchDuration,
    String? pickedTeamLogo,
    String? pickedTeamName,
  }) {
    return Bet(
      id: id ?? this.id,
      matchTitle: matchTitle ?? this.matchTitle,
      date: date ?? this.date,
      stake: stake ?? this.stake,
      odd: odd ?? this.odd,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      pandaMatchId: pandaMatchId ?? this.pandaMatchId,
      pickedTeamId: pickedTeamId ?? this.pickedTeamId,
      gameNumber: gameNumber ?? this.gameNumber,
      side: side ?? this.side,
      myTeamDraft: myTeamDraft ?? this.myTeamDraft,
      enemyTeamDraft: enemyTeamDraft ?? this.enemyTeamDraft,
      towers: towers ?? this.towers,
      dragons: dragons ?? this.dragons,
      totalMatchKills:
          totalMatchKills ?? this.totalMatchKills,
      baronNashors: baronNashors ?? this.baronNashors,
      matchDuration: matchDuration ?? this.matchDuration,
      pickedTeamLogo: pickedTeamLogo ?? this.pickedTeamLogo,
      pickedTeamName: pickedTeamName ?? this.pickedTeamName,
    );
  }
}
