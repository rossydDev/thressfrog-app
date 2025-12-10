import 'package:flutter/material.dart';

import '../../core/services/pandascore_service.dart';
import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/champion_performance.dart';
import '../../models/league_stats_model.dart';
import 'widgets/champion_stat_tile.dart';
import 'widgets/league_card.dart';
import 'widgets/league_detail_page.dart';

class OraclePage extends StatefulWidget {
  const OraclePage({super.key});

  @override
  State<OraclePage> createState() => _OraclePageState();
}

class _OraclePageState extends State<OraclePage> {
  late Future<List<LeagueStats>> _leagueStatsFuture;

  // Variável para controlar o time filtrado (null = todos)
  int? _selectedTeamFilterId;

  @override
  void initState() {
    super.initState();
    _leagueStatsFuture = PandaScoreService()
        .getLeagueStats();
  }

  @override
  Widget build(BuildContext context) {
    // Carrega dados Locais filtrados
    final topChampions = BankrollController.instance
        .getTopChampions(
          filterTeamId: _selectedTeamFilterId,
        );
    final objectiveStats = BankrollController.instance
        .getObjectiveStats(
          filterTeamId: _selectedTeamFilterId,
        );
    final trackedTeams = BankrollController.instance
        .getTrackedTeams();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("LENTE DO ORÁCULO"),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.neonPurple,
            labelColor: AppColors.neonPurple,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(
                icon: Icon(Icons.public),
                text: "GLOBAL (API)",
              ),
              Tab(
                icon: Icon(Icons.auto_stories),
                text: "GRIMÓRIO (VOCÊ)",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- ABA 1: TENDÊNCIAS GLOBAIS (API) ---
            _buildGlobalTrendsTab(),

            // --- ABA 2: SEU GRIMÓRIO (LOCAL) ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // 0. Barra de Filtro de Times (Horizontal)
                  if (trackedTeams.isNotEmpty) ...[
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            trackedTeams.length +
                            1, // +1 para o botão "Todos"
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildFilterChip(
                              label: "Todos",
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
                    const SizedBox(height: 24),
                  ],

                  // 1. Seção de Objetivos (Over/Under)
                  Text(
                    _selectedTeamFilterId == null
                        ? "Médias Gerais"
                        : "Médias do Time Selecionado",
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildObjectiveCard(objectiveStats),

                  const SizedBox(height: 32),

                  // 2. Seção de Campeões (Top Tier)
                  const Text(
                    "Melhores Agentes",
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (topChampions.isEmpty)
                    _buildEmptyState(
                      "Nenhum dado tático registrado para este filtro.\nUse o 'Modo Grimório' ao criar apostas!",
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: topChampions.length > 5
                          ? 5
                          : topChampions
                                .length, // Mostra Top 5
                      itemBuilder: (context, index) {
                        return ChampionStatTile(
                          performance: topChampions[index],
                          index: index,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildFilterChip({
    required String label,
    String? logoUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonPurple
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.neonPurple
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            if (logoUrl != null) ...[
              Image.network(
                logoUrl,
                height: 20,
                width: 20,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shield,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalTrendsTab() {
    return FutureBuilder<List<LeagueStats>>(
      future: _leagueStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.neonPurple,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erro no Oráculo: ${snapshot.error}",
              style: const TextStyle(
                color: AppColors.errorRed,
              ),
            ),
          );
        }

        final stats = snapshot.data ?? [];
        if (stats.isEmpty) {
          return const Center(
            child: Text("Nenhuma tendência encontrada."),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: stats.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 20),
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
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonPurple.withValues(
            alpha: 0.3,
          ),
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
          const Text(
            "Impacto em Vitórias",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
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
              // Barra Vitória
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
                  alignment: Alignment.centerLeft,
                ),
              ),
              // Separador
              Container(
                width: 2,
                height: 12,
                color: Colors.black,
              ),
              // Barra Derrota
              Expanded(
                flex: (lossVal * 10).toInt() + 1,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(
                      alpha: 0.5,
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

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 40,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
