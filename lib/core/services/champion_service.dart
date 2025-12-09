import 'package:dio/dio.dart';

import '../../models/lol_champion_model.dart';

class ChampionService {
  final Dio _dio = Dio();

  // Cache em memória para não baixar toda hora na mesma sessão
  List<LoLChampion> _cachedChampions = [];

  /// 1. Descobre a versão atual do patch (Ex: 13.24.1)
  Future<String> _getLatestVersion() async {
    try {
      final response = await _dio.get(
        'https://ddragon.leagueoflegends.com/api/versions.json',
      );
      final versions = response.data as List;
      return versions.first
          .toString(); // A primeira é sempre a mais recente
    } catch (e) {
      print("Erro ao buscar versão: $e");
      return '13.24.1'; // Fallback se der erro
    }
  }

  /// 2. Baixa a lista de todos os campeões
  Future<List<LoLChampion>> getChampions() async {
    // Se já temos em memória, retorna rápido
    if (_cachedChampions.isNotEmpty) {
      return _cachedChampions;
    }

    try {
      final version = await _getLatestVersion();

      // URL Mágica do DataDragon (pt_BR)
      final url =
          'https://ddragon.leagueoflegends.com/cdn/$version/data/pt_BR/champion.json';

      final response = await _dio.get(url);
      final Map<String, dynamic> data =
          response.data['data'];

      // Converte o JSON (Map) para Lista de Objetos
      final List<LoLChampion> champions = data.values.map((
        json,
      ) {
        return LoLChampion.fromJson(json, version);
      }).toList();

      // Ordena alfabeticamente
      champions.sort((a, b) => a.name.compareTo(b.name));

      _cachedChampions = champions;
      print(
        "📦 ${champions.length} campeões carregados da Riot ($version)!",
      );

      return champions;
    } catch (e) {
      print("Erro ao baixar campeões: $e");
      return [];
    }
  }
}
