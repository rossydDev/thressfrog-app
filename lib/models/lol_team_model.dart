import 'package:hive/hive.dart';

part 'lol_team_model.g.dart';

// ID 6 para Player (para não conflitar com os anteriores)
@HiveType(typeId: 6)
class LoLPlayer extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String nickname; // Ex: "Faker"
  @HiveField(2)
  final String? firstName;
  @HiveField(3)
  final String? lastName;
  @HiveField(4)
  final String? role; // Ex: "mid", "top"
  @HiveField(5)
  final String? photoUrl;

  LoLPlayer({
    required this.id,
    required this.nickname,
    this.firstName,
    this.lastName,
    this.role,
    this.photoUrl,
  });

  factory LoLPlayer.fromJson(Map<String, dynamic> json) {
    return LoLPlayer(
      id: json['id'],
      nickname:
          json['name'], // A API geralmente chama o nick de 'name'
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: json['role'],
      photoUrl: json['image_url'],
    );
  }
}

// ID 7 para Time
@HiveType(typeId: 7)
class LoLTeam extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name; // Ex: "T1"
  @HiveField(2)
  final String acronym; // Ex: "T1"
  @HiveField(3)
  final String logoUrl;

  @HiveField(4)
  final List<LoLPlayer> players; // O elenco atual

  @HiveField(5)
  final DateTime lastUpdated; // O segredo da sincronização!

  @HiveField(6)
  final String? leagueName; // Para facilitar o agrupamento

  LoLTeam({
    required this.id,
    required this.name,
    required this.acronym,
    required this.logoUrl,
    required this.players,
    required this.lastUpdated,
    this.leagueName,
  });

  // Verifica se precisa atualizar (ex: mais de 7 dias)
  bool get isStale {
    final expireDate = lastUpdated.add(
      const Duration(days: 7),
    );
    return DateTime.now().isAfter(expireDate);
  }

  factory LoLTeam.fromJson(
    Map<String, dynamic> json, {
    String? leagueName,
  }) {
    List<LoLPlayer> roster = [];
    if (json['players'] != null) {
      roster = (json['players'] as List)
          .map((p) => LoLPlayer.fromJson(p))
          .toList();
    }

    return LoLTeam(
      id: json['id'],
      name: json['name'],
      acronym: json['acronym'] ?? json['name'],
      logoUrl: json['image_url'] ?? '',
      players: roster,
      lastUpdated:
          DateTime.now(), // Marca o carimbo de tempo atual
      leagueName: leagueName,
    );
  }
}
