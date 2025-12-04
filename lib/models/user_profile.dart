import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
enum InvestorProfile {
  @HiveField(0)
  turtle,
  @HiveField(1)
  frog,
  @HiveField(2)
  alligator,
}

@HiveType(typeId: 3)
class UserProfile {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double initialBankroll;
  @HiveField(2)
  final InvestorProfile profile;

  @HiveField(3)
  final double stopWinPercentage;
  @HiveField(4)
  final double stopLossPercentage;

  // NOVOS CAMPOS DE GAMIFICAÇÃO
  @HiveField(5)
  final int currentLevel;
  @HiveField(6)
  final double currentXP;

  UserProfile({
    required this.name,
    required this.initialBankroll,
    required this.profile,
    double? stopWinPercentage,
    double? stopLossPercentage,
    this.currentLevel = 1, // Começa no Nível 1
    this.currentXP = 0.0, // Começa com 0 XP
  }) : stopWinPercentage =
           stopWinPercentage ?? _defaultWin(profile),
       stopLossPercentage =
           stopLossPercentage ?? _defaultLoss(profile);

  // Lógica de RPG: XP necessário para o próximo nível
  // Fórmula: Nível * 100 (Ex: Nvl 1 precisa de 100XP, Nvl 2 precisa de 200XP...)
  double get xpToNextLevel => currentLevel * 100.0;

  double get progressToLevelUp =>
      (currentXP / xpToNextLevel).clamp(0.0, 1.0);

  // Métodos estáticos mantidos
  static double _defaultWin(InvestorProfile p) {
    if (p == InvestorProfile.turtle) return 0.03;
    if (p == InvestorProfile.alligator) return 0.10;
    return 0.05;
  }

  static double _defaultLoss(InvestorProfile p) {
    if (p == InvestorProfile.turtle) return 0.02;
    if (p == InvestorProfile.alligator) return 0.05;
    return 0.03;
  }

  double get stakePercentage {
    if (profile == InvestorProfile.turtle) return 0.01;
    if (profile == InvestorProfile.alligator) return 0.05;
    return 0.025;
  }

  double suggestedStake(double currentBankroll) =>
      currentBankroll * stakePercentage;

  String get animalEmoji {
    if (profile == InvestorProfile.turtle) return "🐢";
    if (profile == InvestorProfile.alligator) return "🐊";
    return "🐸";
  }

  // Helper para criar uma cópia atualizada (Imutabilidade)
  UserProfile copyWith({
    String? name,
    double? initialBankroll,
    InvestorProfile? profile,
    double? stopWinPercentage,
    double? stopLossPercentage,
    int? currentLevel,
    double? currentXP,
  }) {
    return UserProfile(
      name: name ?? this.name,
      initialBankroll:
          initialBankroll ?? this.initialBankroll,
      profile: profile ?? this.profile,
      stopWinPercentage:
          stopWinPercentage ?? this.stopWinPercentage,
      stopLossPercentage:
          stopLossPercentage ?? this.stopLossPercentage,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXP: currentXP ?? this.currentXP,
    );
  }
}
