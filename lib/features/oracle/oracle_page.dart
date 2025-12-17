import 'package:flutter/material.dart';

import '../../core/logic/prophecy_engine.dart';
import '../../core/services/pandascore_service.dart';
import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/champion_performance.dart';
import '../../models/league_stats_model.dart';
import '../../models/lol_team_model.dart';
import 'widgets/champion_stat_tile.dart';
import 'widgets/grimoire_locked_card.dart'; // [IMPORTANTE] Import do card de bloqueio
import 'widgets/insight_carousel.dart';
import 'widgets/league_card.dart';
import 'widgets/league_detail_page.dart';
import 'widgets/team_detail_page.dart';
import 'widgets/team_search_delegate.dart';

class OraclePage extends StatefulWidget {
  const OraclePage({super.key});

  @override
  State<OraclePage> createState() => _OraclePageState();
}

class _OraclePageState extends State<OraclePage> {
  late Future<List<LeagueStats>> _leagueStatsFuture;
  int? _selectedTeamFilterId;

  @override
  void initState() {
    super.initState();
    _leagueStatsFuture = PandaScoreService()
        .getLeagueStats();
  }

  @override
  Widget build(BuildContext context) {
    final controller = BankrollController.instance;

    // 1. Gera Profecias Globais (Sem filtro)
    final globalInsights = ProphecyEngine.generateInsights(
      controller.bets,
    );
    // 2. Calcula Progresso para desbloqueio
    final validGamesCount = ProphecyEngine.countValidGames(
      controller.bets,
    );

    // 3. Dados Filtrados (Para a parte inferior)
    final topChampions = controller.getTopChampions(
      filterTeamId: _selectedTeamFilterId,
    );
    final objectiveStats = controller.getObjectiveStats(
      filterTeamId: _selectedTeamFilterId,
    );
    final trackedTeams = controller.getTrackedTeams();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // HEADER (Busca)
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.deepBlack,
            elevation: 0,
            titleSpacing: 20,
            title: GestureDetector(
              onTap: () async {
                final result = await showSearch(
                  context: context,
                  delegate: TeamSearchDelegate(),
                );

                if (result != null && result is LoLTeam) {
                  // [NOVO] Navegar para a página de detalhes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeamDetailPage(team: result),
                    ),
                  );
                }
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.search,
                      color: AppColors.neonGreen,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Invocar Time ou Jogador...",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CONTEÚDO SCROLLÁVEL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // SEÇÃO 1: PROFECIAS (Lógica de Bloqueio)
                  if (globalInsights.isNotEmpty) ...[
                    // ESTADO DESBLOQUEADO: Mostra Título + Carrossel
                    const Text(
                      "Profecias do Sapo",
                      style: TextStyle(
                        color: AppColors.neonPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InsightCarousel(
                      insights: globalInsights,
                    ),
                  ] else ...[
                    // ESTADO BLOQUEADO: Mostra Card Trancado (Sem título acima para ficar mais misterioso)
                    GrimoireLockedCard(
                      currentGames: validGamesCount,
                      requiredGames: 3,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // SEÇÃO 2: BIBLIOTECA DE TIMES (Filtros)
                  if (trackedTeams.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Seus Times Rastreados",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedTeamFilterId != null)
                          GestureDetector(
                            onTap: () => setState(
                              () => _selectedTeamFilterId =
                                  null,
                            ),
                            child: const Text(
                              "Limpar",
                              style: TextStyle(
                                color: AppColors.errorRed,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 85,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: trackedTeams.length + 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildFilterChip(
                              label: "Geral",
                              icon: Icons.public,
                              isSelected:
                                  _selectedTeamFilterId ==
                                  null,
                              onTap: () => setState(
                                () =>
                                    _selectedTeamFilterId =
                                        null,
                              ),
                            );
                          }
                          final team =
                              trackedTeams[index - 1];
                          return _buildFilterChip(
                            label: team['name'],
                            logoUrl: team['logo'],
                            isSelected:
                                _selectedTeamFilterId ==
                                team['id'],
                            onTap: () => setState(
                              () => _selectedTeamFilterId =
                                  team['id'],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // SEÇÃO 3: CONTEÚDO DINÂMICO
                  if (_selectedTeamFilterId == null) ...[
                    // MODO GERAL: PANORAMA GLOBAL (API)
                    const Text(
                      "Panorama das Ligas (Global)",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGlobalLeaguesList(),
                  ] else ...[
                    // MODO TIME: ESTATÍSTICAS ESPECÍFICAS
                    const Text(
                      "Médias de Combate",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildObjectiveCard(objectiveStats),
                    const SizedBox(height: 32),

                    const Text(
                      "Sinergia de Agentes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (topChampions.isEmpty)
                      _buildEmptyBox(
                        "Sem dados de campeões para este time.",
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: topChampions.length > 5
                            ? 5
                            : topChampions.length,
                        itemBuilder: (context, index) =>
                            ChampionStatTile(
                              performance:
                                  topChampions[index],
                              index: index,
                            ),
                      ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildFilterChip({
    required String label,
    String? logoUrl,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.neonPurple.withOpacity(0.2)
                  : AppColors.surfaceDark,
              border: Border.all(
                color: isSelected
                    ? AppColors.neonPurple
                    : Colors.white10,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: logoUrl != null
                ? ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(
                              Icons.shield,
                              color: Colors.white24,
                            ),
                      ),
                    ),
                  )
                : Icon(
                    icon ?? Icons.shield,
                    color: isSelected
                        ? AppColors.neonPurple
                        : Colors.white24,
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? AppColors.neonPurple
                    : Colors.white54,
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaguesList() {
    return FutureBuilder<List<LeagueStats>>(
      future: _leagueStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: AppColors.neonPurple,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildEmptyBox(
            "Erro ao conectar com a API Global.",
          );
        }
        final stats = snapshot.data ?? [];
        if (stats.isEmpty)
          return _buildEmptyBox("Nenhuma liga encontrada.");

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return LeagueCard(
              stats: stat,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LeagueDetailPage(stats: stat),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildObjectiveCard(ObjectiveStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceDark, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat(
                "Média Kills",
                stats.avgKills.toStringAsFixed(1),
                Icons.my_location,
                Colors.redAccent,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white10,
              ),
              _buildMiniStat(
                "Duração",
                "${stats.avgDuration.toStringAsFixed(0)} min",
                Icons.timer,
                Colors.tealAccent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildComparisonRow(
            "Torres",
            stats.avgTowersWin,
            stats.avgTowersLoss,
            AppColors.neonPurple,
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(
            "Dragões",
            stats.avgDragonsWin,
            stats.avgDragonsLoss,
            Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(
    String label,
    double winVal,
    double lossVal,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: (winVal * 10).toInt() + 1,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 12,
                color: Colors.black,
              ),
              Expanded(
                flex: (lossVal * 10).toInt() + 1,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(
                      0.5,
                    ),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "${winVal.toStringAsFixed(1)} vs ${lossVal.toStringAsFixed(1)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white24),
      ),
    );
  }
}
