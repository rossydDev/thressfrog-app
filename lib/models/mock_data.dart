import 'bet_model.dart';

class MockData {
  static final List<Bet> bets = [
    Bet(
      id: '1',
      matchTitle: 'T1 vs Gen.G',
      date: DateTime.now().subtract(
        const Duration(hours: 2),
      ),
      stake: 50.00,
      odd: 1.85,
      result: .loss,
      notes: "Tentei pegar o First Blood, mas falou",
    ),
    Bet(
      id: '2',
      matchTitle: 'Pain vs Loud',
      date: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      stake: 100.00,
      odd: 2.10,
      result: .win,
      notes: "Draft da Pain estava muito superior.",
    ),
    Bet(
      id: '3',
      matchTitle: 'JDG vs BLG',
      date: DateTime.now().add(const Duration(hours: 4)),
      stake: 75.00,
      odd: 1.50,
      result: .pending,
      notes: "Aposta de segurança na JDG",
    ),
    Bet(
      id: '4',
      matchTitle: 'G2 vs Fnatic',
      date: DateTime.now().subtract(
        const Duration(days: 2),
      ),
      stake: 30.00,
      odd: 3.50,
      result: .win,
    ),
  ];

  static const double currentBankroll = 1342.50;
}
