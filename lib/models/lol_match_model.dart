class LoLMatch {
  final int id;
  final String name; // Ex: "T1 vs Gen.G"
  final DateTime scheduledAt;
  final String leagueName;
  final String? leagueLogo;
  final Team? teamA;
  final Team? teamB;

  LoLMatch({
    required this.id,
    required this.name,
    required this.scheduledAt,
    required this.leagueName,
    this.leagueLogo,
    this.teamA,
    this.teamB,
  });

  // Fábrica para criar o objeto a partir do JSON da PandaScore
  factory LoLMatch.fromJson(Map<String, dynamic> json) {
    final opponents = json['opponents'] as List;

    // Pega os dois primeiros times (às vezes a lista vem vazia se o time não foi definido)
    Team? t1;
    Team? t2;

    if (opponents.isNotEmpty) {
      t1 = Team.fromJson(opponents[0]['opponent']);
      if (opponents.length > 1) {
        t2 = Team.fromJson(opponents[1]['opponent']);
      }
    }

    return LoLMatch(
      id: json['id'],
      name: json['name'] ?? "Partida Indefinida",
      scheduledAt: DateTime.parse(json['scheduled_at']),
      leagueName: json['league']['name'] ?? 'LoL',
      leagueLogo: json['league']['image_url'],
      teamA: t1,
      teamB: t2,
    );
  }
}

class Team {
  final int id;
  final String name;
  final String? logoUrl;
  final String acronym;

  Team({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.acronym,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'] ?? "Team",
      logoUrl: json['image_url'],
      acronym: json['acronym'] ?? "",
    );
  }
}
