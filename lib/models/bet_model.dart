import 'package:hive/hive.dart';

part 'bet_model.g.dart';

// [NOVO] Enum para definir o lado do mapa (Azul/Vermelho)
@HiveType(typeId: 4)
enum LoLSide {
  @HiveField(0)
  blue,
  @HiveField(1)
  red,
}

@HiveType(typeId: 1)
enum BetResult {
  @HiveField(0)
  pending,
  @HiveField(1)
  win,
  @HiveField(2)
  loss,
  @HiveField(3)
  voided, // Anulada/Devolvida
  @HiveField(4)
  halfWin, // Ganhou metade
  @HiveField(5)
  halfLoss, // Perdeu metade
}

@HiveType(typeId: 0)
class Bet extends HiveObject {
  // --- CAMPOS ANTIGOS (Mantidos) ---
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String matchTitle; // Ex: "T1 vs Gen.G"

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

  @HiveField(7)
  final int? pandaMatchId;

  @HiveField(8)
  final int? gameNumber;

  @HiveField(9)
  final LoLSide? side;

  @HiveField(10)
  final int? pickedTeamId;

  Bet({
    required this.id,
    required this.matchTitle,
    required this.date,
    required this.stake,
    required this.odd,
    required this.result,
    required this.notes,
    this.pandaMatchId,
    this.gameNumber,
    this.side,
    this.pickedTeamId,
  });

  // Getters Úteis
  bool get isGreen =>
      result == BetResult.win ||
      result == BetResult.halfWin;
  bool get isRed =>
      result == BetResult.loss ||
      result == BetResult.halfLoss;

  // Cálculo de Lucro/Prejuízo Real
  double get netImpact {
    if (result == BetResult.win) {
      return (stake * odd) - stake;
    }
    if (result == BetResult.halfWin) {
      return ((stake * odd) - stake) / 2;
    }
    if (result == BetResult.loss) return -stake;
    if (result == BetResult.halfLoss) return -stake / 2;
    return 0.0; // pending ou voided
  }

  // Método copyWith para facilitar edições mantendo os dados novos
  Bet copyWith({
    String? id,
    String? matchTitle,
    DateTime? date,
    double? stake,
    double? odd,
    BetResult? result,
    String? notes,
    int? pandaMatchId,
    int? gameNumber,
    LoLSide? side,
    int? pickedTeamId,
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
      gameNumber: gameNumber ?? this.gameNumber,
      side: side ?? this.side,
      pickedTeamId: pickedTeamId ?? this.pickedTeamId,
    );
  }

  double get potentialReturn => stake * odd;

  double get profit => netImpact;
}
