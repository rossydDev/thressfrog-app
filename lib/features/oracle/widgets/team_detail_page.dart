import 'package:flutter/material.dart';

import '../../../core/state/bankroll_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/bet_model.dart'; // [IMPORTANTE] Importar o modelo de aposta
import '../../../models/lol_team_model.dart';
import '../widgets/champion_stat_tile.dart';

class TeamDetailPage extends StatelessWidget {
  final LoLTeam team;

  const TeamDetailPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    // Busca dados específicos deste time no seu histórico
    final controller = BankrollController.instance;
    final stats = controller.getObjectiveStats(
      filterTeamId: team.id,
    );
    final topChampions = controller.getTopChampions(
      filterTeamId: team.id,
    );

    // [CORREÇÃO] Usando b.result == BetResult.win em vez de b.isWin
    final teamBets = controller.bets
        .where(
          (b) =>
              b.pickedTeamId == team.id &&
              (b.result == BetResult.win ||
                  b.result == BetResult.loss),
        )
        .toList();

    final totalGames = teamBets.length;

    // Contagem de vitórias
    final wins = teamBets
        .where((b) => b.result == BetResult.win)
        .length;

    final winRate = totalGames > 0
        ? wins / totalGames
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: CustomScrollView(
        slivers: [
          // 1. HEADER EXPANSÍVEL (Com Logo e Elenco)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.deepBlack,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.neonPurple.withOpacity(0.2),
                      AppColors.deepBlack,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Logo do Time
                    Hero(
                      tag: 'team_logo_${team.id}',
                      child: Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neonPurple,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonPurple
                                  .withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: team.logoUrl.isNotEmpty
                            ? Image.network(
                                team.logoUrl,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(
                                          Icons.shield,
                                          size: 50,
                                          color:
                                              Colors.white,
                                        ),
                              )
                            : const Icon(
                                Icons.shield,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      team.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "${team.players.length} JOGADORES REGISTRADOS",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. CONTEÚDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // --- SEÇÃO A: LINE-UP (JOGADORES) ---
                  if (team.players.isNotEmpty) ...[
                    const Text(
                      "Escalação Atual",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: team.players.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final player =
                              team.players[index];
                          return _buildPlayerCard(player);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- SEÇÃO B: SEU DESEMPENHO (Winrate) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                      border: Border.all(
                        color: Colors.white10,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sua Taxa de Vitória",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${(winRate * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            "$totalGames JOGOS",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- SEÇÃO C: ESTATÍSTICAS TÁTICAS ---
                  const Text(
                    "Médias de Combate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    "Kills",
                    stats.avgKills.toStringAsFixed(1),
                    Icons.my_location,
                  ),
                  _buildStatRow(
                    "Torres",
                    stats.avgTowersWin.toStringAsFixed(1),
                    Icons.castle,
                  ),
                  _buildStatRow(
                    "Dragões",
                    stats.avgDragonsWin.toStringAsFixed(1),
                    Icons.water_drop,
                  ),

                  const SizedBox(height: 32),

                  // --- SEÇÃO D: MELHORES CAMPEÕES ---
                  if (topChampions.isNotEmpty) ...[
                    const Text(
                      "Sinergia de Agentes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: topChampions.length > 3
                          ? 3
                          : topChampions.length,
                      itemBuilder: (context, index) =>
                          ChampionStatTile(
                            performance:
                                topChampions[index],
                            index: index,
                          ),
                    ),
                  ] else ...[
                    _buildEmptyState(
                      "Sem dados de campeões para este time.",
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(LoLPlayer player) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Foto do Jogador
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: ClipOval(
              child: player.photoUrl != null
                  ? Image.network(
                      player.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(
                            Icons.person,
                            color: Colors.white24,
                          ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white24,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Nick
          Text(
            player.nickname,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Role
          Text(
            player.role?.toUpperCase() ?? "FLX",
            style: const TextStyle(
              color: AppColors.neonPurple,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(
          color: Colors.white24,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
