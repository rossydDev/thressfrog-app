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

  UserProfile({
    required this.name,
    required this.initialBankroll,
    required this.profile,
  });

  // Lógica simplificada para evitar erros de sintaxe
  double get stakePercentage {
    if (profile == InvestorProfile.turtle) {
      return 0.01; // 1%
    } else if (profile == InvestorProfile.alligator) {
      return 0.05; // 5%
    } else {
      return 0.025; // 2.5% (Frog/Padrão)
    }
  }

  double suggestedStake(double currentBankroll) {
    double value = currentBankroll * stakePercentage;

    return value > 1 ? value : currentBankroll;
  }

  String get profileName {
    if (profile == InvestorProfile.turtle) {
      return "A Tartaruga";
    }
    if (profile == InvestorProfile.alligator) {
      return "O Jacaré";
    }
    return "O Sapo";
  }
}
