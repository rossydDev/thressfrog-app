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

  @HiveField(5)
  final int currentLevel;
  @HiveField(6)
  final double currentXP;

  @HiveField(7)
  final bool ghostMode;

  @HiveField(8)
  final double ghostTriggerPercentage;

  @HiveField(9)
  final List<String> achivements;

  UserProfile({
    required this.name,
    required this.initialBankroll,
    required this.profile,
    double? stopWinPercentage,
    double? stopLossPercentage,
    this.currentLevel = 1,
    this.currentXP = 0.0,
    this.ghostMode = false,
    this.ghostTriggerPercentage = 0.50,
    this.achivements = const [],
  }) : // Usamos os métodos estáticos públicos agora
       stopWinPercentage =
           stopWinPercentage ?? defaultWin(profile),
       stopLossPercentage =
           stopLossPercentage ?? defaultLoss(profile);

  // --- TORNAMOS PÚBLICOS (Sem o '_') PARA USAR NA UI ---
  static double defaultWin(InvestorProfile p) {
    if (p == InvestorProfile.turtle) return 0.03; // 3%
    if (p == InvestorProfile.alligator) return 0.10; // 10%
    return 0.05; // 5%
  }

  static double defaultLoss(InvestorProfile p) {
    if (p == InvestorProfile.turtle) return 0.02; // 2%
    if (p == InvestorProfile.alligator) return 0.05; // 5%
    return 0.03; // 3%
  }
  // -----------------------------------------------------

  double get stakePercentage {
    if (profile == InvestorProfile.turtle) return 0.01;
    if (profile == InvestorProfile.alligator) return 0.05;
    return 0.025;
  }

  double suggestedStake(double currentBankroll) =>
      currentBankroll * stakePercentage;

  // Lógica de RPG
  double get xpToNextLevel => currentLevel * 100.0;
  double get progressToLevelUp =>
      (currentXP / xpToNextLevel).clamp(0.0, 1.0);

  String get animalEmoji {
    if (profile == InvestorProfile.turtle) return "🐢";
    if (profile == InvestorProfile.alligator) return "🐊";
    return "🐸";
  }

  UserProfile copyWith({
    String? name,
    double? initialBankroll,
    InvestorProfile? profile,
    double? stopWinPercentage,
    double? stopLossPercentage,
    int? currentLevel,
    double? currentXP,
    bool? ghostMode,
    double? ghostTriggerPercentage,
    List<String>? achivements,
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
      ghostMode: ghostMode ?? this.ghostMode,
      ghostTriggerPercentage:
          ghostTriggerPercentage ??
          this.ghostTriggerPercentage,
      achivements: achivements ?? this.achivements,
    );
  }
}
