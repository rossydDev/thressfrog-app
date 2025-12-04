import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/bet_model.dart';
import '../../models/user_profile.dart';

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
    // Ordena da mais nova para a mais antiga (Lista da UI)
    _bets.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  void setUserProfile(UserProfile user) {
    _userProfile = user;
    // Se a banca for 0 (primeira vez), inicializa
    if (_currentBalance == 0) {
      _currentBalance = user.initialBankroll;
      _settingsBox.put('balance', _currentBalance);
    }
    _settingsBox.put('user_profile', user);
    notifyListeners();
  }

  // --- CRUD (Criação, Edição, Exclusão) ---

  void addBet(Bet bet) {
    _bets.insert(0, bet);
    _currentBalance -=
        bet.stake; // O dinheiro sai da banca ao apostar

    _betsBox.put(bet.id, bet);
    _settingsBox.put('balance', _currentBalance);

    notifyListeners();
  }

  void resolveBet(Bet bet, BetResult newResult) {
    // 1. Reverte o impacto financeiro atual (Neutraliza)
    _currentBalance -= bet.netImpact;

    // 2. Calcula o novo impacto
    double newImpact = 0;
    if (newResult == BetResult.win) {
      newImpact = (bet.stake * bet.odd) - bet.stake;
    } else if (newResult == BetResult.loss) {
      newImpact = -bet.stake;
    } else if (newResult == BetResult.pending) {
      newImpact = -bet.stake;
    }
    // Void = 0

    // 3. Aplica
    _currentBalance += newImpact;

    // 4. Atualiza o objeto
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
    // Devolve o dinheiro para a banca (desfaz a aposta)
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

  // --- SISTEMA THRESHOLD (METAS DO DIA) --- 🛡️

  // 1. Quanto lucrei hoje?
  double get profitTodayRaw {
    final now = DateTime.now();
    // Filtra apostas com a mesma data de hoje
    final todayBets = _bets.where((b) {
      return b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day;
    });

    double total = 0;
    for (var bet in todayBets) {
      // Só conta lucro de apostas FECHADAS (não pendentes)
      if (bet.result != BetResult.pending) {
        total += bet.profit;
      }
    }
    return total;
  }

  // 2. Qual é o valor monetário da meta? (Baseado na % do perfil)
  double get stopWinValue =>
      _currentBalance *
      (_userProfile?.stopWinPercentage ?? 0.05);
  double get stopLossValue =>
      _currentBalance *
      (_userProfile?.stopLossPercentage ?? 0.03);

  // 3. Progresso (0.0 a 1.0) para as Barras de Vida
  double get stopWinProgress {
    if (profitTodayRaw <= 0) return 0.0;
    return (profitTodayRaw / stopWinValue).clamp(0.0, 1.0);
  }

  double get stopLossProgress {
    if (profitTodayRaw >= 0) return 0.0;
    // Usa .abs() porque prejuízo é negativo
    return (profitTodayRaw.abs() / stopLossValue).clamp(
      0.0,
      1.0,
    );
  }

  // 4. Status Binário (Bateu ou não?)
  bool get isStopLossHit =>
      profitTodayRaw <= -stopLossValue;
  bool get isStopWinHit => profitTodayRaw >= stopWinValue;

  // --- DADOS PARA O GRÁFICO ---
  List<FlSpot> get chartData {
    if (_userProfile == null) return [];

    // Começa com a banca inicial
    double runningBalance = _userProfile!.initialBankroll;

    // Ponto 0
    final List<FlSpot> spots = [FlSpot(0, runningBalance)];

    // Precisamos da ordem cronológica (Antigo -> Novo) para o gráfico desenhar certo
    final chronologicalBets = _bets.reversed.toList();

    for (int i = 0; i < chronologicalBets.length; i++) {
      final bet = chronologicalBets[i];
      runningBalance += bet.netImpact;
      spots.add(FlSpot((i + 1).toDouble(), runningBalance));
    }
    return spots;
  }

  // Getters visuais
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

  void resetBankroll() {
    _currentBalance = 100.00;
    _bets.clear();
    _betsBox.clear();
    _settingsBox.delete('user_profile');
    _settingsBox.put('balance', 100.00);
    _userProfile = null;
    notifyListeners();
  }
}
