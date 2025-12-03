enum BetResult { win, loss, pending, voided }

class Bet {
  final String id;
  final String matchTitle;
  final DateTime date;
  final double stake;
  final double odd;
  final BetResult result;
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

  double get potentialReturn => stake * odd;

  double get profit {
    switch (result) {
      case .win:
        return (potentialReturn) - stake;
      case .loss:
        return -stake;
      case .voided:
      case .pending:
        return 0.0;
    }
  }

  bool get isGreen => result == .win;
}
