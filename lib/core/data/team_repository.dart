import 'package:hive/hive.dart';

import '../../models/lol_team_model.dart';
import '../services/pandascore_service.dart';

class TeamRepository {
  static final TeamRepository instance = TeamRepository._();

  TeamRepository._();

  Box<LoLTeam> get _box => Hive.box<LoLTeam>('known_teams');
  final _api = PandaScoreService();

  /// O Método Mágico: Lazy Sync
  /// 1. Tenta pegar local.
  /// 2. Se não existir ou estiver velho (>7 dias) -> Busca na API.
  /// 3. Salva e retorna.
  Future<LoLTeam?> getTeamSmart(int teamId) async {
    // 1. Busca Local
    final localTeam = _box.get(teamId);

    // Se existe e está "fresco" (não stale), retorna o local (Rápido!)
    if (localTeam != null && !localTeam.isStale) {
      print(
        "🐸 Cache Hit: Time $teamId carregado do Hive.",
      );
      return localTeam;
    }

    // 2. Se não existe ou está velho, busca na API
    print(
      "🌐 Cache Miss/Stale: Buscando time $teamId na API...",
    );
    try {
      final data = await _api.getTeamDetails(teamId);

      if (data != null) {
        // Converte JSON para nosso Modelo
        final newTeam = LoLTeam.fromJson(data);

        // 3. Salva no Hive (Sobrescreve o antigo se existir)
        await _box.put(teamId, newTeam);

        return newTeam;
      }
    } catch (e) {
      print("Erro no Repositório: $e");
      // Se der erro na API (sem internet), tenta retornar o local velho como fallback
      if (localTeam != null) return localTeam;
    }

    return null;
  }

  /// Busca apenas na API (para a barra de pesquisa)
  Future<List<LoLTeam>> searchOnline(String query) async {
    final results = await _api.searchTeams(query);

    // Converte e já salva no cache para uso futuro!
    final List<LoLTeam> teams = [];
    for (var json in results) {
      final team = LoLTeam.fromJson(json);
      teams.add(team);
      // Opcional: Salvar os resultados da busca no cache também
      _box.put(team.id, team);
    }
    return teams;
  }
}
