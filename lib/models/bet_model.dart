import 'package:hive/hive.dart';

part 'bet_model.g.dart';

@HiveType(typeId: 0)
enum BetResult {
  @HiveField(0)
  win,
  @HiveField(1)
  loss,
  @HiveField(2)
  pending,
  @HiveField(3)
  voided,
}

@HiveType(typeId: 1)
class Bet {
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
  final String? notes;

  Bet({
    required this.id,
    required this.matchTitle,
    required this.date,
    required this.stake,
    required this.odd,
    this.result = BetResult.pending,
    this.notes,
  });

  // Lógica de Negócio (Getters) continua intacta
  double get potentialReturn => stake * odd;

  double get profit {
    switch (result) {
      case BetResult.win:
        return potentialReturn - stake;
      case BetResult.loss:
        return -stake;
      case BetResult.voided:
      case BetResult.pending:
        return 0.0;
    }
  }

  bool get isGreen => result == BetResult.win;

  double get netImpact {
    switch (result) {
      case .pending:
      case .loss:
        return -stake;
      case .win:
        return potentialReturn - stake;
      case .voided:
        return 0.0;
    }
  }
}
