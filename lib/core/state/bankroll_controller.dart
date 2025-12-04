import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/bet_model.dart';
import '../../models/user_profile.dart'; // Importe o modelo

class BankrollController extends ChangeNotifier {
  static final BankrollController instance =
      BankrollController._();

  Box get _settingsBox => Hive.box('settings');
  Box<Bet> get _betsBox => Hive.box<Bet>('bets');

  BankrollController._() {
    _loadData();
  }

  double _currentBalance = 0.0;
  List<Bet> _bets = [];
  UserProfile? _userProfile;

  double get currentBalance => _currentBalance;
  List<Bet> get bets => List.unmodifiable(_bets);
  UserProfile? get userProfile => _userProfile;

  void _loadData() {
    if (!Hive.isBoxOpen('settings') ||
        !Hive.isBoxOpen('bets')) {
      return;
    }

    if (_settingsBox.containsKey('user_profile')) {
      _userProfile =
          _settingsBox.get('user_profile') as UserProfile?;
    }

    if (_settingsBox.containsKey('balance')) {
      _currentBalance = _settingsBox.get('balance');
    } else if (_userProfile != null) {
      _currentBalance = _userProfile!.initialBankroll;
    }

    _bets = _betsBox.values.toList();
    _bets.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  // --- AÇÕES ---

  // Método chamado pela tela de Onboarding
  void setUserProfile(UserProfile user) {
    _userProfile = user;
    _currentBalance = user.initialBankroll;

    _settingsBox.put('user_profile', user);
    _settingsBox.put('balance', _currentBalance);

    notifyListeners();
  }

  void addBet(Bet bet) {
    _bets.insert(0, bet);
    _currentBalance -= bet.stake;

    _betsBox.put(bet.id, bet);
    _settingsBox.put('balance', _currentBalance);

    notifyListeners();
  }

  void resolveBet(Bet bet, BetResult newResult) {
    _currentBalance -= bet.netImpact;

    double newImpact = 0;

    if (newResult == .win) {
      newImpact = bet.potentialReturn - bet.stake;
    } else if (newResult == .loss) {
      newImpact = -bet.stake;
    } else {
      newImpact = 0;
    }

    _currentBalance += newImpact;

    final updateBet = Bet(
      id: bet.id,
      matchTitle: bet.matchTitle,
      date: bet.date,
      odd: bet.odd,
      stake: bet.stake,
      notes: bet.notes,
      result: newResult,
    );

    final index = _bets.indexWhere((b) => b.id == bet.id);

    if (index != -1) {
      _bets[index] = updateBet;
    }

    _betsBox.put(updateBet.id, updateBet);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }

  void deleteBet(Bet bet) {
    _currentBalance -= bet.netImpact;

    _bets.removeWhere((b) => b.id == bet.id);
    _betsBox.delete(bet.id);

    _settingsBox.put("balance", _currentBalance);
    notifyListeners();
  }

  void updateBet(Bet oldBet, Bet newBet) {
    _currentBalance -= oldBet.netImpact;

    _currentBalance += newBet.netImpact;

    final index = _bets.indexWhere(
      (b) => b.id == oldBet.id,
    );
    if (index != -1) {
      _bets[index] = newBet;
    }

    _betsBox.put(newBet.id, newBet);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }

  void resetBankroll() {
    _currentBalance = 100.00;
    _bets.clear();
    _betsBox.clear();
    _settingsBox.delete(
      'user_profile',
    ); // Apaga o usuário também
    _settingsBox.put('balance', 100.00);
    _userProfile = null;
    notifyListeners();
  }

  // Helper getters
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

  List<FlSpot> get chartData {
    if (_userProfile == null) {
      return [];
    }

    double runningBalance = _userProfile!.initialBankroll;
    final List<FlSpot> spots = [];

    spots.add(FlSpot(0, runningBalance));

    final chronologicalBets = _bets.reversed.toList();

    for (int i = 0; i < chronologicalBets.length; i++) {
      final bet = chronologicalBets[i];
      runningBalance += bet.netImpact;

      spots.add(FlSpot((i + 1).toDouble(), runningBalance));
    }

    if (spots.length > 20) {
      final last20 = spots.sublist(spots.length - 20);
      return last20
          .map((e) => FlSpot(e.x - last20.first.x, e.y))
          .toList();
    }

    return spots;
  }
}
