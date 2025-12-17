import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/bet_model.dart';
import '../../models/champion_performance.dart';
import '../../models/user_profile.dart'; //

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

  // --- GETTERS PÚBLICOS ---
  double get currentBalance => _currentBalance;
  List<Bet> get bets => List.unmodifiable(_bets);

  // [CORREÇÃO FINAL] Getter 'user' ajustado para os nomes corretos
  UserProfile get user =>
      _userProfile ??
      UserProfile(
        name: "Invocador",
        initialBankroll: 100.0,
        // [CORREÇÃO]: currentBankroll não existe no construtor
        profile: InvestorProfile
            .frog, // [CORREÇÃO]: Era 'moderate', agora é 'frog'
      );

  UserProfile? get userProfile => _userProfile;

  void _loadData() {
    if (!Hive.isBoxOpen('settings') ||
        !Hive.isBoxOpen('bets')) {
      return;
    }

    // Carrega Perfil
    if (_settingsBox.containsKey('user_profile')) {
      _userProfile =
          _settingsBox.get('user_profile') as UserProfile?;
    } else {
      // Cria padrão se não existir
      _userProfile = UserProfile(
        name: "Invocador",
        initialBankroll: 100.0,
        // [CORREÇÃO]: Usando 'frog' em vez de 'moderate'
        profile: InvestorProfile.frog,
      );
      _settingsBox.put('user_profile', _userProfile);
    }

    // Carrega Saldo
    if (_settingsBox.containsKey('balance')) {
      _currentBalance = _settingsBox.get('balance');
    } else {
      _currentBalance = _userProfile!.initialBankroll;
    }

    // Carrega Apostas
    _bets = _betsBox.values.toList();
    _bets.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  // [MÉTODO NOVO] Chamado pela ProfilePage para salvar alterações
  void updateUser(UserProfile newUser) {
    setUserProfile(newUser);
  }

  void setUserProfile(UserProfile user) {
    _userProfile = user;

    // Se o saldo estiver zerado (primeiro uso), ajusta para o inicial do perfil
    if (_currentBalance == 0) {
      _currentBalance = user.initialBankroll;
      _settingsBox.put('balance', _currentBalance);
    }

    _settingsBox.put('user_profile', user);
    _checkAchievements();
    notifyListeners();
  }

  // --- MÉTODOS DE AÇÃO (APOSTAS) ---

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
    // Tolerância de R$1.0 acima da sugestão
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
              "Sem XP: GHOST ATIVADO! Você devolveu todo o lucro do dia.",
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
        message: "Sem XP: Meta do dia já batida. Descanse!",
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
    // 1. REVERTER O ESTADO FINANCEIRO ATUAL
    if (bet.result == BetResult.pending) {
      _currentBalance += bet.stake;
    } else if (bet.result == BetResult.loss) {
      _currentBalance += bet.stake;
    } else if (bet.result == BetResult.win) {
      final profit = (bet.stake * bet.odd) - bet.stake;
      _currentBalance -= profit;
    }

    // 2. APLICAR O NOVO ESTADO
    if (newResult == BetResult.pending) {
      _currentBalance -= bet.stake;
    } else if (newResult == BetResult.loss) {
      _currentBalance -= bet.stake;
    } else if (newResult == BetResult.win) {
      final profit = (bet.stake * bet.odd) - bet.stake;
      _currentBalance += profit;
    }

    // 3. ATUALIZAR OBJETO E BANCO
    final updatedBet = bet.copyWith(result: newResult);

    final index = _bets.indexWhere((b) => b.id == bet.id);
    if (index != -1) _bets[index] = updatedBet;
    _betsBox.put(updatedBet.id, updatedBet);
    _settingsBox.put('balance', _currentBalance);

    _checkAchievements();
    notifyListeners();
  }

  void deleteBet(Bet bet) {
    if (bet.result == BetResult.pending) {
      _currentBalance += bet.stake;
    } else if (bet.result == BetResult.loss) {
      _currentBalance += bet.stake;
    } else if (bet.result == BetResult.win) {
      final profit = (bet.stake * bet.odd) - bet.stake;
      _currentBalance -= profit;
    }

    _bets.removeWhere((b) => b.id == bet.id);
    _betsBox.delete(bet.id);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }

  void updateBet(Bet oldBet, Bet newBet) {
    if (oldBet.result == BetResult.pending) {
      _currentBalance += oldBet.stake;
    }
    if (newBet.result == BetResult.pending) {
      _currentBalance -= newBet.stake;
    }

    final index = _bets.indexWhere(
      (b) => b.id == oldBet.id,
    );
    if (index != -1) _bets[index] = newBet;
    _betsBox.put(newBet.id, newBet);
    _settingsBox.put('balance', _currentBalance);
    notifyListeners();
  }

  // --- GETTERS DE ESTATÍSTICAS ---

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
    if (isGhostModeTriggered) return 0.0;
    return -stopLossValue;
  }

  void _checkAchievements() {
    if (_userProfile == null) return;
    final List<String> currentBadges = List.from(
      _userProfile!.achivements,
    );
    final List<String> newBadges = [];

    void unlock(String id) {
      if (!currentBadges.contains(id)) {
        currentBadges.add(id);
        newBadges.add(id);
      }
    }

    if (_bets.isNotEmpty) unlock('first_bet');
    if (_bets.any((b) => b.result == BetResult.win)) {
      unlock('winner');
    }
    if (_bets.length >= 10) unlock('scholar');
    if (_currentBalance >= 1000.0) unlock('rich_frog');
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
      if (wins / finishedBets.length >= 0.60) {
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

  Map<String, double> getUserSideStats() {
    int blueWins = 0,
        blueGames = 0,
        redWins = 0,
        redGames = 0;

    for (var bet in _bets) {
      if (bet.result != BetResult.pending &&
          bet.result != BetResult.voided &&
          bet.side != null) {
        if (bet.side == LoLSide.blue) {
          blueGames++;
          if (bet.result == BetResult.win) blueWins++;
        } else if (bet.side == LoLSide.red) {
          redGames++;
          if (bet.result == BetResult.win) redWins++;
        }
      }
    }

    return {
      'blueWinRate': blueGames > 0
          ? blueWins / blueGames
          : 0.0,
      'blueTotal': blueGames.toDouble(),
      'redWinRate': redGames > 0 ? redWins / redGames : 0.0,
      'redTotal': redGames.toDouble(),
    };
  }

  // --- MÉTODOS DO GRIMÓRIO (COM FILTRO DE TIME) ---

  List<ChampionPerformance> getTopChampions({
    int? filterTeamId,
  }) {
    final Map<String, Map<String, dynamic>> statsMap = {};

    for (var bet in _bets) {
      if (bet.result == BetResult.pending ||
          bet.result == BetResult.voided) {
        continue;
      }
      if (bet.myTeamDraft == null ||
          bet.myTeamDraft!.isEmpty) {
        continue;
      }

      // FILTRO DE TIME
      if (filterTeamId != null &&
          bet.pickedTeamId != filterTeamId) {
        continue;
      }

      final profit = bet.netImpact;
      final isWin = bet.result == BetResult.win;

      for (var champId in bet.myTeamDraft!) {
        if (!statsMap.containsKey(champId)) {
          statsMap[champId] = {
            'games': 0,
            'wins': 0,
            'profit': 0.0,
          };
        }
        statsMap[champId]!['games'] += 1;
        statsMap[champId]!['profit'] += profit;
        if (isWin) statsMap[champId]!['wins'] += 1;
      }
    }

    final List<ChampionPerformance> performanceList = [];
    statsMap.forEach((id, data) {
      performanceList.add(
        ChampionPerformance(
          championId: id,
          totalGames: data['games'],
          wins: data['wins'],
          netProfit: data['profit'],
        ),
      );
    });

    performanceList.sort(
      (a, b) => b.netProfit.compareTo(a.netProfit),
    );
    return performanceList;
  }

  ObjectiveStats getObjectiveStats({int? filterTeamId}) {
    int winCount = 0, lossCount = 0;
    int towersWin = 0, towersLoss = 0;
    int dragonsWin = 0, dragonsLoss = 0;
    int totalKills = 0,
        totalDuration = 0,
        gamesWithStats = 0;

    for (var bet in _bets) {
      if (bet.result == BetResult.pending ||
          bet.result == BetResult.voided) {
        continue;
      }
      if (filterTeamId != null &&
          bet.pickedTeamId != filterTeamId) {
        continue;
      }

      if (bet.totalMatchKills != null &&
          bet.matchDuration != null) {
        totalKills += bet.totalMatchKills!;
        totalDuration += bet.matchDuration!;
        gamesWithStats++;
      }

      if (bet.towers != null && bet.dragons != null) {
        if (bet.result == BetResult.win) {
          winCount++;
          towersWin += bet.towers!;
          dragonsWin += bet.dragons!;
        } else if (bet.result == BetResult.loss) {
          lossCount++;
          towersLoss += bet.towers!;
          dragonsLoss += bet.dragons!;
        }
      }
    }

    return ObjectiveStats(
      avgTowersWin: winCount > 0
          ? towersWin / winCount
          : 0.0,
      avgTowersLoss: lossCount > 0
          ? towersLoss / lossCount
          : 0.0,
      avgDragonsWin: winCount > 0
          ? dragonsWin / winCount
          : 0.0,
      avgDragonsLoss: lossCount > 0
          ? dragonsLoss / lossCount
          : 0.0,
      avgKills: gamesWithStats > 0
          ? totalKills / gamesWithStats
          : 0.0,
      avgDuration: gamesWithStats > 0
          ? totalDuration / gamesWithStats
          : 0.0,
    );
  }

  List<Map<String, dynamic>> getTrackedTeams() {
    final Map<int, Map<String, dynamic>> teams = {};

    for (var bet in _bets) {
      if (bet.pickedTeamId != null &&
          bet.pickedTeamName != null) {
        if (!teams.containsKey(bet.pickedTeamId)) {
          teams[bet.pickedTeamId!] = {
            'id': bet.pickedTeamId,
            'name': bet.pickedTeamName,
            'logo': bet.pickedTeamLogo,
          };
        }
      }
    }
    return teams.values.toList();
  }

  void updateCapital(double amount) {
    if (_userProfile == null) return;

    // 1. Atualiza o Saldo Atual
    _currentBalance += amount;

    // 2. Atualiza a Banca Inicial
    // (Isso é necessário para que o gráfico não ache que esse dinheiro veio de lucro de aposta)
    final newInitial =
        _userProfile!.initialBankroll + amount;

    final updatedUser = _userProfile!.copyWith(
      initialBankroll: newInitial,
    );

    // 3. Salva tudo
    _userProfile = updatedUser;
    _settingsBox.put('user_profile', updatedUser);
    _settingsBox.put('balance', _currentBalance);

    notifyListeners();
  }
}
