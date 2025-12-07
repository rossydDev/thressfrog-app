import 'package:dio/dio.dart';

import '../../models/league_stats_model.dart';
import '../../models/lol_match_model.dart';

class PandaScoreService {
  final Dio _dio = Dio();

  // 🔑 Lembre de colocar sua chave aqui ou usar .env
  static const String _token =
      'TFGMNjBRDKJbMvwRDslF706PpW3hD2nMdUToGv-DaOjZUWbqp3o';

  // Ligas Padrão (Big 5 + KeSPA para testes agora)
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

  /// Busca os jogos futuros (Mantido)
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

  /// Busca os últimos jogos finalizados filtrando pelas ligas escolhidas
  Future<List<dynamic>> _fetchRawPastMatches(
    List<String> leagues,
  ) async {
    // Transforma a lista ["LCK", "CBLOL"] em uma string "LCK,CBLOL" para a API
    final leagueFilter = leagues.join(',');

    try {
      final response = await _dio.get(
        '/lol/matches/past',
        queryParameters: {
          'sort': '-end_at',
          'page[size]':
              50, // Analisa 50 jogos para ter uma boa média
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
  /// Aceita uma lista opcional de ligas preferidas. Se null, usa o padrão.
  Future<List<LeagueStats>> getLeagueStats({
    List<String>? preferredLeagues,
  }) async {
    // Se o usuário não passou nada, usa as ligas padrão
    final targets = preferredLeagues ?? defaultLeagues;

    // Busca os dados brutos filtrados
    final rawMatches = await _fetchRawPastMatches(targets);

    // Mapa para agrupar jogos por Liga
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

    // Calcula as médias
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

            // Simulação de Side para o MVP (já que API Free não garante 'side' na lista)
            // No futuro, usaríamos game['position'] ou similar
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

    return statsList;
  }
}
