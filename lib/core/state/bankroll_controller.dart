import 'package:flutter/material.dart';

import '../../models/bet_model.dart';

class BankrollController extends ChangeNotifier {
  static final BankrollController instance =
      BankrollController._();
  BankrollController._();

  double _currentBalance = 100.00;
  final List<Bet> _bets = [];

  double get currentBalance => _currentBalance;
  List<Bet> get bets => List.unmodifiable(_bets);

  String get winRate {
    if (_bets.isEmpty) return "0%";
    final wins = _bets
        .where((b) => b.result == .win)
        .length;
    final rate = (wins / _bets.length) * 100;
    return rate.toStringAsFixed(0);
  }

  double get todayProfit {
    double total = 0;
    for (var bet in _bets) {
      total += bet.profit;
    }

    return total;
  }

  void addBet(Bet bet) {
    _bets.insert(0, bet);

    _currentBalance -= bet.stake;

    notifyListeners();
  }
}
