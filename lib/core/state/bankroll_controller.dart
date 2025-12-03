import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/bet_model.dart';

class BankrollController extends ChangeNotifier {
  static final BankrollController instance =
      BankrollController._();

  // EM VEZ DE LATE, USAMOS GETTERS DIRETOS
  // Isso é mais seguro: se a caixa estiver aberta, ele pega.
  // Se não estiver, ele lança um erro mais claro de "Box not found" em vez de LateError.
  Box get _settingsBox => Hive.box('settings');
  Box<Bet> get _betsBox => Hive.box<Bet>('bets');

  BankrollController._() {
    _loadData(); // Mudamos o nome para ficar mais claro
  }

  double _currentBalance = 100.00;
  List<Bet> _bets = [];

  double get currentBalance => _currentBalance;
  List<Bet> get bets => List.unmodifiable(_bets);

  void _loadData() {
    // Bloco de segurança: Tenta carregar, se a caixa não estiver pronta, não quebra o app
    if (!Hive.isBoxOpen('settings') ||
        !Hive.isBoxOpen('bets')) {
      print(
        "⚠️ ERRO CRÍTICO: As caixas do Hive não foram abertas no main.dart!",
      );
      return;
    }

    _currentBalance = _settingsBox.get(
      'balance',
      defaultValue: 100.00,
    );

    _bets = _betsBox.values.toList();
    _bets.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  // ... Resto dos Getters (winRate, todayProfit) IGUAIS ao anterior ...
  String get winRate {
    final finishedBets = _bets
        .where(
          (b) =>
              b.result != BetResult.pending &&
              b.result != BetResult.voided,
        )
        .toList();
    if (finishedBets.isEmpty) return "0%";
    final wins = finishedBets
        .where((b) => b.result == BetResult.win)
        .length;
    final rate = (wins / finishedBets.length) * 100;
    return "${rate.toStringAsFixed(0)}%";
  }

  double get todayProfit {
    double total = 0;
    for (var bet in _bets) {
      if (bet.result != BetResult.pending) {
        total += bet.profit;
      }
    }
    return total;
  }

  // --- AÇÕES ---

  void addBet(Bet bet) {
    _bets.insert(0, bet);
    _currentBalance -= bet.stake;

    // Acesso direto via getter seguro
    _betsBox.put(bet.id, bet);
    _settingsBox.put('balance', _currentBalance);

    notifyListeners();
  }

  void resolveBet(Bet bet, BetResult newResult) {
    if (newResult == BetResult.win) {
      _currentBalance += (bet.stake * bet.odd);
    } else if (newResult == BetResult.voided) {
      _currentBalance += bet.stake;
    }

    final updatedBet = Bet(
      id: bet.id,
      matchTitle: bet.matchTitle,
      date: bet.date,
      stake: bet.stake,
      odd: bet.odd,
      notes: bet.notes,
      result: newResult,
    );

    final index = _bets.indexWhere((b) => b.id == bet.id);
    if (index != -1) {
      _bets[index] = updatedBet;
    }

    // Acesso direto via getter seguro
    _betsBox.put(updatedBet.id, updatedBet);
    _settingsBox.put('balance', _currentBalance);

    notifyListeners();
  }

  void resetBankroll() {
    _currentBalance = 100.00;
    _bets.clear();
    _betsBox.clear();
    _settingsBox.put('balance', 100.00);
    notifyListeners();
  }
}
