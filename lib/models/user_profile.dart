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

  // NOVOS CAMPOS: Porcentagens customizáveis
  @HiveField(3)
  final double stopWinPercentage;
  @HiveField(4)
  final double stopLossPercentage;

  UserProfile({
    required this.name,
    required this.initialBankroll,
    required this.profile,
    double? stopWinPercentage,
    double? stopLossPercentage,
  }) : stopWinPercentage =
           stopWinPercentage ?? _defaultWin(profile),
       stopLossPercentage =
           stopLossPercentage ?? _defaultLoss(profile);

  // MÉTODOS ESTÁTICOS DE AJUDA
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
}
