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

  double _currentBalance =
      0.0; // Começa zerado até carregar
  List<Bet> _bets = [];
  UserProfile?
  _userProfile; // Variável para guardar o perfil

  double get currentBalance => _currentBalance;
  List<Bet> get bets => List.unmodifiable(_bets);
  UserProfile? get userProfile =>
      _userProfile; // Getter público

  void _loadData() {
    if (!Hive.isBoxOpen('settings') ||
        !Hive.isBoxOpen('bets'))
      return;

    // 1. Tenta carregar o usuário salvo
    // O Hive pode retornar dynamic, então fazemos cast
    if (_settingsBox.containsKey('user_profile')) {
      _userProfile =
          _settingsBox.get('user_profile') as UserProfile?;
    }

    // 2. Carrega o saldo.
    // SE tiver saldo salvo, usa.
    // SE NÃO (primeira vez), usa a banca inicial do perfil ou 0.
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
    _currentBalance =
        user.initialBankroll; // Define a banca inicial

    // Salva tudo no disco
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

    _betsBox.put(updatedBet.id, updatedBet);
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
}
