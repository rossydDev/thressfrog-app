import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/pandascore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/lol_match_model.dart';

class SelectMatchScreen extends StatefulWidget {
  const SelectMatchScreen({super.key});

  @override
  State<SelectMatchScreen> createState() =>
      _SelectMatchScreenState();
}

class _SelectMatchScreenState
    extends State<SelectMatchScreen> {
  final PandaScoreService _service = PandaScoreService();
  late Future<List<LoLMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _service.fetchUpcomingMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JOGOS AO VIVO & FUTUROS"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: AppColors.neonGreen,
        ),
      ),
      backgroundColor: AppColors.deepBlack, // Fundo escuro
      body: FutureBuilder<List<LoLMatch>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          // 1. Carregando
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonGreen,
              ),
            );
          }

          // 2. Erro
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: AppColors.errorRed,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Erro ao buscar jogos.\nVerifique sua conexão ou a API Key.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _matchesFuture = _service
                            .fetchUpcomingMatches();
                      });
                    },
                    child: const Text("Tentar Novamente"),
                  ),
                ],
              ),
            );
          }

          // 3. Sucesso mas vazio
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum jogo de LoL encontrado hoje.",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          // 4. Lista de Jogos
          final matches = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            // ignore: unnecessary_underscores
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final match = matches[index];
              return _buildMatchCard(match);
            },
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(LoLMatch match) {
    final dateFormat = DateFormat('dd/MM HH:mm');

    return InkWell(
      onTap: () {
        // Retorna o nome do jogo para a tela anterior
        Navigator.pop(context, match.name);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        child: Column(
          children: [
            // Cabeçalho: Liga e Hora
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (match.leagueLogo != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 6,
                    ),
                    child: Image.network(
                      match.leagueLogo!,
                      height: 16,
                      width: 16,
                    ),
                  ),
                Text(
                  "${match.leagueName} • ${dateFormat.format(match.scheduledAt)}",
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Times e VS
            Row(
              children: [
                // TIME A (Esquerda)
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(match.teamA?.logoUrl),
                      const SizedBox(height: 6),
                      Text(
                        match.teamA?.name ?? "TBD",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // VS
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: const Text(
                    "VS",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // TIME B (Direita)
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(match.teamB?.logoUrl),
                      const SizedBox(height: 6),
                      Text(
                        match.teamB?.name ?? "TBD",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? url) {
    if (url == null) {
      return Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.question_mark,
          color: Colors.white24,
          size: 20,
        ),
      );
    }
    return Image.network(
      url,
      height: 40,
      width: 40,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.error_outline,
          color: Colors.white24,
        );
      },
    );
  }
}
