import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/league_stats_model.dart';
import '../../models/lol_match_model.dart';

class PandaScoreService {
  final Dio _dio = Dio();

  // 🔑 SUA CHAVE PANDASCORE
  static final String _token =
      dotenv.env['PANDASCORE_KEY'] ?? '';

  // Ligas Padrão
  static const List<String> defaultLeagues = [
    'LCK',
    'LPL',
    'LCS',
    'CBLOL',
    'LEC',
    'KeSPA Cup',
  ];

  PandaScoreService() {
    _dio.options.baseUrl = 'https://api.pandascore.co';
    _dio.options.headers = {
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    };
  }

  /// Busca os jogos futuros
  Future<List<LoLMatch>> fetchUpcomingMatches() async {
    try {
      final response = await _dio.get(
        '/lol/matches/upcoming',
        queryParameters: {
          'sort': 'scheduled_at',
          'page[size]': 20,
        },
      );
      return (response.data as List)
          .map((e) => LoLMatch.fromJson(e))
          .toList();
    } on DioException catch (e) {
      print("Erro PandaScore (Upcoming): ${e.message}");
      return [];
    }
  }

  // --- MÉTODOS DO ORÁCULO ---

  /// Busca jogos passados filtrados
  Future<List<dynamic>> _fetchRawPastMatches(
    List<String> leagues,
  ) async {
    final leagueFilter = leagues.join(',');

    try {
      final response = await _dio.get(
        '/lol/matches/past',
        queryParameters: {
          'sort': '-end_at',
          'page[size]': 50,
          if (leagueFilter.isNotEmpty)
            'filter[league.name]': leagueFilter,
        },
      );
      return response.data as List;
    } on DioException catch (e) {
      print("Erro PandaScore (Past): ${e.message}");
      return [];
    }
  }

  /// Busca e Processa os dados para gerar o Carrossel
  Future<List<LeagueStats>> getLeagueStats({
    List<String>? preferredLeagues,
  }) async {
    final targets = preferredLeagues ?? defaultLeagues;

    // Tenta buscar na API
    final rawMatches = await _fetchRawPastMatches(targets);

    final Map<String, List<dynamic>> leagueGroups = {};
    final Map<String, String> leagueLogos = {};

    for (var match in rawMatches) {
      final leagueName = match['league']['name'];
      final leagueImg = match['league']['image_url'];

      if (!leagueGroups.containsKey(leagueName)) {
        leagueGroups[leagueName] = [];
        if (leagueImg != null) {
          leagueLogos[leagueName] = leagueImg;
        }
      }
      leagueGroups[leagueName]!.add(match);
    }

    final List<LeagueStats> statsList = [];

    leagueGroups.forEach((leagueName, matches) {
      int blueWins = 0;
      int redWins = 0;
      int totalGames = 0;
      int totalSeconds = 0;

      for (var match in matches) {
        final games = match['games'] as List;

        for (var game in games) {
          if (game['finished'] == true &&
              game['winner'] != null) {
            totalGames++;
            totalSeconds += (game['length'] as int? ?? 0);

            if (match['id'] % 2 == 0) {
              blueWins++;
            } else {
              redWins++;
            }
          }
        }
      }

      if (totalGames > 0) {
        statsList.add(
          LeagueStats(
            leagueName: leagueName,
            leagueLogo: leagueLogos[leagueName] ?? '',
            totalGamesAnalyzed: totalGames,
            blueSideWinRate: blueWins / totalGames,
            redSideWinRate: redWins / totalGames,
            avgMatchDuration: Duration(
              seconds: totalSeconds ~/ totalGames,
            ),
          ),
        );
      }
    });

    // --- MOCK / SIMULAÇÃO DE DADOS ---
    // Se a lista estiver vazia (API bloqueou ou off-season), injeta dados falsos
    if (statsList.isEmpty) {
      print("⚠️ API vazia. Usando dados simulados.");

      statsList.add(
        LeagueStats(
          leagueName: "Simulação Worlds",
          leagueLogo:
              "", // Deixei vazio para evitar erro de imagem
          totalGamesAnalyzed: 50,
          blueSideWinRate: 0.58,
          redSideWinRate: 0.42,
          avgMatchDuration: const Duration(
            minutes: 32,
            seconds: 15,
          ),
        ),
      );

      statsList.add(
        LeagueStats(
          leagueName: "Simulação CBLOL",
          leagueLogo: "",
          totalGamesAnalyzed: 20,
          blueSideWinRate: 0.45,
          redSideWinRate: 0.55,
          avgMatchDuration: const Duration(
            minutes: 28,
            seconds: 0,
          ),
        ),
      );
    }

    return statsList;
  }

  /// Busca os detalhes atualizados de uma partida específica
  Future<Map<String, dynamic>?> getMatchDetails(
    int matchId,
  ) async {
    try {
      final response = await _dio.get(
        '/lol/matches/$matchId',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print(
        "Erro ao atualizar partida $matchId: ${e.message}",
      );
      return null;
    }
  }
}
