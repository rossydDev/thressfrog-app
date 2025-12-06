import 'package:dio/dio.dart';

import '../../models/lol_match_model.dart';

class PandaScoreService {
  final Dio _dio = Dio();

  static const String _token =
      'TFGMNjBRDKJbMvwRDslF706PpW3hD2nMdUToGv-DaOjZUWbqp3o';

  PandaScoreService() {
    _dio.options.baseUrl = 'https://api.pandascore.co';
    _dio.options.headers = {
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    };
  }

  /// Busca as próximas 50 partidas de LoL
  Future<List<LoLMatch>> fetchUpcomingMatches() async {
    try {
      final response = await _dio.get(
        '/lol/matches/upcoming',
        queryParameters: {
          'sort': 'scheduled_at', // Ordenar por data
          'page[size]': 20, // Trazer 20 jogos
        },
      );

      // Mapeia a lista de JSON para nossa lista de Objetos
      return (response.data as List)
          .map((e) => LoLMatch.fromJson(e))
          .toList();
    } on DioException {
      return []; // Retorna lista vazia em caso de erro (MVP)
    }
  }
}
