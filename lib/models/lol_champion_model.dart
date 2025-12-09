class LoLChampion {
  final String
  id; // Ex: "LeeSin" (usado para buscar imagem)
  final String name; // Ex: "Lee Sin"
  final String title; // Ex: "O Monge Cego"
  final List<String> tags; // Ex: ["Fighter", "Assassin"]
  final String imageUrl; // URL completa da imagem

  LoLChampion({
    required this.id,
    required this.name,
    required this.title,
    required this.tags,
    required this.imageUrl,
  });

  // Fábrica para criar a partir do JSON da Riot
  factory LoLChampion.fromJson(
    Map<String, dynamic> json,
    String version,
  ) {
    return LoLChampion(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      tags: List<String>.from(json['tags']),
      // Monta a URL da imagem direto do CDN da Riot
      imageUrl:
          'https://ddragon.leagueoflegends.com/cdn/$version/img/champion/${json['id']}.png',
    );
  }
}
