import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/bet_model.dart';
import '../../models/user_profile.dart';

class XPResult {
  final bool gainedXP;
  final bool leveledUp;
  final int xpAmount;
  final String message;

  XPResult({
    this.gainedXP = false,
    this.leveledUp = false,
    this.xpAmount = 0,
    this.message = "",
  });
}

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
        !Hive.isBoxOpen('bets'))
      return;
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

  void setUserProfile(UserProfile user) {
    _userProfile = user;
    if (_currentBalance == 0) {
      _currentBalance = user.initialBankroll;
      _settingsBox.put('balance', _currentBalance);
    }
    _settingsBox.put('user_profile', user);
    notifyListeners();
  }

  // --- MÉTODOS DE AÇÃO ---

  XPResult addBet(Bet bet) {
    _bets.insert(0, bet);
    _currentBalance -= bet.stake;
    _betsBox.put(bet.id, bet);
    _settingsBox.put('balance', _currentBalance);

    XPResult result = XPResult(
      message: "Perfil não configurado.",
    );
    if (_userProfile != null) {
      result = _checkAndAwardXP(bet);
    }

    notifyListeners();
    return result;
  }

  XPResult _checkAndAwardXP(Bet bet) {
    // 1. Regra da Stake
    final suggested = _userProfile!.suggestedStake(
      _currentBalance + bet.stake,
    );
    final bool isStakeCorrect =
        bet.stake <=
        (suggested + 1.0); // Tolerância R$ 1.00

    if (!isStakeCorrect) {
      return XPResult(
        message:
            "Sem XP: Stake de R\$${bet.stake} é alta para seu perfil (Sugerido: R\$${suggested.toStringAsFixed(2)})",
      );
    }

    // 2. Regra do Limite (Threshold) - COM VALORES REAIS NA MENSAGEM
    // Recalcula aqui para ter certeza
    final profitToday = profitTodayRaw;
    final sWin = stopWinValue;
    final sLoss = stopLossValue;

    if (profitToday <= -sLoss) {
      // Stop Loss Batido
      return XPResult(
        message:
            "Sem XP: Stop Loss atingido (-R\$${profitToday.abs().toStringAsFixed(2)} / -R\$${sLoss.toStringAsFixed(2)})",
      );
    }

    // ATENÇÃO: Se o lucro hoje já for maior que a meta, não dá XP
    if (profitToday >= sWin) {
      return XPResult(
        message:
            "Sem XP: Meta do dia já batida (+R\$${profitToday.toStringAsFixed(2)}). Descanse!",
      );
    }

    // Se passou por tudo, ganha XP!
    return _grantXP(10);
  }

  XPResult _grantXP(double amount) {
    if (_userProfile == null) return XPResult();

    double newXP = _userProfile!.currentXP + amount;
    int newLevel = _userProfile!.currentLevel;
    double xpNeeded = _userProfile!.xpToNextLevel;
    bool leveledUp = false;

    if (newXP >= xpNeeded) {
      newXP -= xpNeeded;
      newLevel++;
      leveledUp = true;
    }

    final updatedUser = _userProfile!.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
    );

    setUserProfile(updatedUser);

    return XPResult(
      gainedXP: true,
      leveledUp: leveledUp,
      xpAmount: amount.toInt(),
      message: "Disciplina Férrea! +${amount.toInt()} XP",
    );
  }

  // --- CRUD BASE (IGUAL ANTES) ---
  void resolveBet(Bet bet, BetResult newResult) {
    _currentBalance -= bet.netImpact;
    double newImpact = 0;
    if (newResult == BetResult.win)
      newImpact = (bet.stake * bet.odd) - bet.stake;
    else if (newResult == BetResult.loss)
      newImpact = -bet.stake;
    else if (newResult == BetResult.pending)
      newImpact = -bet.stake;
    _currentBalance += newImpact;
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
    if (index != -1) _bets[index] = updatedBet;
    _betsBox.put(updatedBet.id, updatedBet);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }

  void deleteBet(Bet bet) {
    _currentBalance -= bet.netImpact;
    _bets.removeWhere((b) => b.id == bet.id);
    _betsBox.delete(bet.id);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }

  void updateBet(Bet oldBet, Bet newBet) {
    _currentBalance -= oldBet.netImpact;
    _currentBalance += newBet.netImpact;
    final index = _bets.indexWhere(
      (b) => b.id == oldBet.id,
    );
    if (index != -1) _bets[index] = newBet;
    _betsBox.put(newBet.id, newBet);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }

  // --- GETTERS E HELPERS ---
  double get profitTodayRaw {
    final now = DateTime.now();
    final todayBets = _bets.where(
      (b) =>
          b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day,
    );
    double total = 0;
    for (var bet in todayBets) {
      if (bet.result != BetResult.pending)
        total += bet.profit;
    }
    return total;
  }

  double get stopWinValue =>
      _currentBalance *
      (_userProfile?.stopWinPercentage ?? 0.05);
  double get stopLossValue =>
      _currentBalance *
      (_userProfile?.stopLossPercentage ?? 0.03);

  double get stopWinProgress {
    if (profitTodayRaw <= 0) return 0.0;
    return (profitTodayRaw / stopWinValue).clamp(0.0, 1.0);
  }

  double get stopLossProgress {
    if (profitTodayRaw >= 0) return 0.0;
    return (profitTodayRaw.abs() / stopLossValue).clamp(
      0.0,
      1.0,
    );
  }

  bool get isStopLossHit =>
      profitTodayRaw <= -stopLossValue;
  bool get isStopWinHit => profitTodayRaw >= stopWinValue;

  List<FlSpot> get chartData {
    if (_userProfile == null) return [];
    double runningBalance = _userProfile!.initialBankroll;
    final List<FlSpot> spots = [FlSpot(0, runningBalance)];
    final chronologicalBets = _bets.reversed.toList();
    for (int i = 0; i < chronologicalBets.length; i++) {
      final bet = chronologicalBets[i];
      runningBalance += bet.netImpact;
      spots.add(FlSpot((i + 1).toDouble(), runningBalance));
    }
    return spots;
  }

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

  double get todayProfit => profitTodayRaw;

  // MÉTODO NOVO: RESET TOTAL (O Botão de Pânico)
  void fullReset() {
    _bets.clear();
    _betsBox.clear(); // Limpa as apostas

    // Reseta o perfil para o básico, mantendo o nome se quiser, ou apaga tudo
    // Vamos apagar tudo para começar do zero mesmo
    _currentBalance = 100.0;
    _settingsBox.put('balance', 100.0);

    if (_userProfile != null) {
      final resetUser = _userProfile!.copyWith(
        currentXP: 0.0,
        currentLevel: 1,
        initialBankroll: 100.0, // Volta para 100
      );
      setUserProfile(resetUser);
    }

    notifyListeners();
  }

  void updateUserProfileAndBalance(
    UserProfile user,
    double newBalance,
  ) {
    _userProfile = user;
    _currentBalance = newBalance;
    _settingsBox.put('user_profile', user);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }
}
