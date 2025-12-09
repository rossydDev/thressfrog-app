import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/bet_model.dart';
import '../../models/user_profile.dart';
import '../services/pandascore_service.dart'; // [NOVO] Import necessário

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

  void setUserProfile(UserProfile user) {
    _userProfile = user;
    if (_currentBalance == 0) {
      _currentBalance = user.initialBankroll;
      _settingsBox.put('balance', _currentBalance);
    }
    _settingsBox.put('user_profile', user);

    _checkAchievements();
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

    _checkAchievements();
    notifyListeners();
    return result;
  }

  XPResult _checkAndAwardXP(Bet bet) {
    final suggested = _userProfile!.suggestedStake(
      _currentBalance + bet.stake,
    );
    final bool isStakeCorrect =
        bet.stake <= (suggested + 1.0);

    if (!isStakeCorrect) {
      return XPResult(
        message:
            "Sem XP: Stake de R\$${bet.stake} é alta para seu perfil...",
      );
    }

    final profitToday = profitTodayRaw;
    final limitFloor = currentStopLossLimit;

    if (profitToday < limitFloor) {
      if (isGhostModeTriggered) {
        return XPResult(
          message:
              "Sem XP: GHOST ATIVADO! Você devolveu todo o lucro do dia. Pare no 0x0.",
        );
      } else {
        return XPResult(
          message:
              "Sem XP: Stop Loss atingido (-R\$${profitToday.abs().toStringAsFixed(2)}).",
        );
      }
    }

    final sWin = stopWinValue;
    if (profitToday >= sWin) {
      return XPResult(
        message:
            "Sem XP: Meta do dia já batida (+R\$${profitToday.toStringAsFixed(2)}). Descanse!",
      );
    }

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

  void resolveBet(Bet bet, BetResult newResult) {
    _currentBalance -= bet.netImpact;
    double newImpact = 0;
    if (newResult == BetResult.win) {
      newImpact = (bet.stake * bet.odd) - bet.stake;
    } else if (newResult == BetResult.loss) {
      newImpact = -bet.stake;
    } else if (newResult == BetResult.pending) {
      newImpact = -bet.stake;
    }

    _currentBalance += newImpact;
    final updatedBet = Bet(
      id: bet.id,
      matchTitle: bet.matchTitle,
      date: bet.date,
      stake: bet.stake,
      odd: bet.odd,
      notes: bet.notes,
      result: newResult,
      // Mantém os dados novos
      pandaMatchId: bet.pandaMatchId,
      pickedTeamId: bet.pickedTeamId,
      gameNumber: bet.gameNumber,
      side: bet.side,
    );
    final index = _bets.indexWhere((b) => b.id == bet.id);
    if (index != -1) _bets[index] = updatedBet;
    _betsBox.put(updatedBet.id, updatedBet);
    _settingsBox.put('balance', _currentBalance);

    _checkAchievements();
    notifyListeners();
  }

  // --- [NOVO] SINCRONIZAÇÃO AUTOMÁTICA ---
  Future<int> syncPendingBets() async {
    int updatedCount = 0;
    final service = PandaScoreService();

    // 1. Filtra só as pendentes que são oficiais
    final pendingOfficialBets = _bets
        .where(
          (b) =>
              b.result == BetResult.pending &&
              b.pandaMatchId != null,
        )
        .toList();

    for (var bet in pendingOfficialBets) {
      // 2. Chama a API
      final matchData = await service.getMatchDetails(
        bet.pandaMatchId!,
      );

      if (matchData != null) {
        final status =
            matchData['status']; // 'finished', 'running', 'not_started'

        if (status == 'finished') {
          // 3. Descobre quem ganhou
          final winnerId = matchData['winner_id'];

          if (winnerId != null &&
              bet.pickedTeamId != null) {
            // 4. Compara e Resolve
            if (winnerId == bet.pickedTeamId) {
              resolveBet(
                bet,
                BetResult.win,
              ); // GREEN AUTOMÁTICO!
            } else {
              resolveBet(
                bet,
                BetResult.loss,
              ); // RED AUTOMÁTICO.
            }
            updatedCount++;
          }
        }
      }
    }

    // Se atualizou alguém, notifica a tela
    if (updatedCount > 0) notifyListeners();

    return updatedCount;
  }
  // ---------------------------------------

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
      if (bet.result != BetResult.pending) {
        total += bet.profit;
      }
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
    final profit = profitTodayRaw;

    if (isGhostModeTriggered) {
      if (profit < 0) return 1.0;
      return 0.0;
    }

    if (profit >= 0) return 0.0;
    return (profit.abs() / stopLossValue).clamp(0.0, 1.0);
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

  void fullReset() {
    _bets.clear();
    _betsBox.clear();
    _currentBalance = 100.0;
    _settingsBox.put('balance', 100.0);

    if (_userProfile != null) {
      final resetUser = _userProfile!.copyWith(
        currentXP: 0.0,
        currentLevel: 1,
        initialBankroll: 100.0,
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

  bool get isGhostModeTriggered {
    if (_userProfile == null || !_userProfile!.ghostMode) {
      return false;
    }

    return profitTodayRaw >=
        (stopWinValue *
            _userProfile!.ghostTriggerPercentage);
  }

  double get currentStopLossLimit {
    if (isGhostModeTriggered) {
      return 0.0;
    }

    return -stopLossValue;
  }

  void _checkAchievements() {
    if (_userProfile == null) return;

    final List<String> currentBadges = List.from(
      _userProfile!
          .achivements, // Ajustado para 'achievements' (correção de typo)
    );
    final List<String> newBadges = [];

    void unlock(String id) {
      if (!currentBadges.contains(id)) {
        currentBadges.add(id);
        newBadges.add(id);
      }
    }

    if (_bets.isNotEmpty) {
      unlock('first_bet');
    }

    if (_bets.any((b) => b.result == BetResult.win)) {
      unlock('winner');
    }

    if (_bets.length >= 10) {
      unlock('scholar');
    }

    if (_currentBalance >= 1000.0) {
      unlock('rich_frog');
    }

    if (_userProfile!.currentLevel >= 5) {
      unlock('discipline');
    }

    final finishedBets = _bets
        .where(
          (b) =>
              b.result == BetResult.win ||
              b.result == BetResult.loss,
        )
        .toList();
    if (finishedBets.length >= 10) {
      final wins = finishedBets
          .where((b) => b.result == BetResult.win)
          .length;
      final winRate = wins / finishedBets.length;
      if (winRate >= 0.60) {
        unlock('sniper');
      }
    }

    if (newBadges.isNotEmpty) {
      final updatedUser = _userProfile!.copyWith(
        achivements: currentBadges,
      );
      _userProfile = updatedUser;
      _settingsBox.put('user_profile', updatedUser);
      notifyListeners();
    }
  }
}
