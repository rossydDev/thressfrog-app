import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:thressfrog_app/features/oracle/widgets/league_card.dart';
import 'package:thressfrog_app/features/oracle/widgets/league_detail_page.dart';

import '../../core/services/pandascore_service.dart';
import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bet_model.dart';
import '../../models/league_stats_model.dart';

class OraclePage extends StatefulWidget {
  const OraclePage({super.key});

  @override
  State<OraclePage> createState() => _OraclePageState();
}

class _OraclePageState extends State<OraclePage> {
  final _pandaService = PandaScoreService();

  // Estado do Carrossel Global
  late Future<List<LeagueStats>> _leagueStatsFuture;

  // Ligas Ativas (Filtro do Usuário)
  List<String> _activeLeagues = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // 1. Carrega as preferências do Hive ou usa o padrão
  void _loadPreferences() {
    final box = Hive.box('settings');
    final savedLeagues = box.get(
      'oracle_leagues',
      defaultValue: null,
    );

    if (savedLeagues != null) {
      // Converte a lista dinâmica do Hive para List<String>
      _activeLeagues = List<String>.from(savedLeagues);
    } else {
      // Se nunca salvou, usa as padrões do Serviço
      _activeLeagues = List.from(
        PandaScoreService.defaultLeagues,
      );
    }

    _refreshStats();
  }

  // Atualiza a busca na API com as ligas atuais
  void _refreshStats() {
    setState(() {
      _leagueStatsFuture = _pandaService.getLeagueStats(
        preferredLeagues: _activeLeagues,
      );
    });
  }

  // 2. O Dialog de Escolha (Dropdown/Modal)
  void _showFilterDialog() {
    // Lista de todas as opções que queremos oferecer
    final allOptions = [
      'CBLOL',
      'LCK',
      'LPL',
      'LEC',
      'LCS',
      'KeSPA Cup',
      'Worlds',
      'MSI',
      'LJL',
      'PCS',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        // StatefulBuilder permite atualizar os checkboxes dentro do Dialog sem fechar
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppColors.neonPurple,
                  width: 1,
                ),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AppColors.neonPurple,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Filtrar Ligas",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allOptions.map((league) {
                    final isSelected = _activeLeagues
                        .contains(league);
                    return CheckboxListTile(
                      title: Text(
                        league,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      value: isSelected,
                      activeColor: AppColors.neonPurple,
                      checkColor: Colors.black,
                      side: const BorderSide(
                        color: Colors.white54,
                      ),
                      onChanged: (bool? val) {
                        setStateDialog(() {
                          if (val == true) {
                            _activeLeagues.add(league);
                          } else {
                            _activeLeagues.remove(league);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "CANCELAR",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Salva no Hive e recarrega a tela
                    Hive.box(
                      'settings',
                    ).put('oracle_leagues', _activeLeagues);
                    _refreshStats();
                    Navigator.pop(ctx);
                  },
                  child: const Text("APLICAR FILTRO"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtra apostas manuais vs oficiais
    final officialBets = BankrollController.instance.bets
        .where((bet) {
          return bet.pandaMatchId != null &&
              bet.pickedTeamId != null;
        })
        .toList();

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: const Text("LENTE DO ORÁCULO"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: AppColors.neonPurple,
        ),
        actions: [
          // BOTÃO DE FILTRO (Funciona como um Dropdown avançado)
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            tooltip: "Escolher Campeonatos",
            onPressed: _showFilterDialog,
          ),
          // Botão de Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEÇÃO 1: CARROSSEL DE LIGAS ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                10,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tendências Globais",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Mostra quantas ligas estão ativas no filtro
                  Text(
                    "${_activeLeagues.length} ligas ativas",
                    style: const TextStyle(
                      color: AppColors.neonPurple,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 180,
              child: FutureBuilder<List<LeagueStats>>(
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
                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return _buildEmptyState(
                      "Nenhum dado encontrado para as ligas selecionadas.\nTente adicionar 'KeSPA Cup' no filtro.",
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final stats = snapshot.data![index];

                      return LeagueCard(
                        stats: stats,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LeagueDetailPage(
                                    stats: stats,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // --- SEÇÃO 2: PERFORMANCE PESSOAL ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Sua Performance Oficial",
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (officialBets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: const [
                    Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "O Oráculo precisa de dados oficiais.\nUse a busca automática ao criar apostas para desbloquear análises.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildMyStats(officialBets),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildMyStats(List<Bet> bets) {
    final sideStats = BankrollController.instance
        .getUserSideStats();

    final blueRate = sideStats['blueWinRate'] ?? 0.0;
    final redRate = sideStats['redWinRate'] ?? 0.0;
    final totalGamesWithSide =
        (sideStats['blueTotal']! + sideStats['redTotal']!)
            .toInt();

    // Se o usuário não definiu lados em nenhuma aposta, mostra o básico
    if (totalGamesWithSide == 0) {
      return _buildSimpleStats(
        bets,
      ); // O card antigo simples
    }

    // 2. Monta o Card Visual Rico (Reaproveitando o estilo do LeagueCard)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceDark,
            const Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonGreen.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(
                    alpha: 0.2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seu Side Control",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Baseado nas suas escolhas manuais",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BARRA DE DUELO (Igual a do LeagueCard, mas com seus dados)
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BLUE ${(blueRate * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${(redRate * 100).toStringAsFixed(0)}% RED",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(
                alpha: 0.2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Flexible(
                  flex:
                      (blueRate * 100).toInt() == 0 &&
                          (redRate * 100).toInt() == 0
                      ? 50
                      : (blueRate * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(
                        4,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex:
                      (blueRate * 100).toInt() == 0 &&
                          (redRate * 100).toInt() == 0
                      ? 50
                      : ((1 - blueRate) * 100).toInt(),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "$totalGamesWithSide jogos com lado identificado",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSimpleStats(List<Bet> bets) {
  // ... seu código antigo do card simples ...
  return const Center(
    child: Text(
      "Defina o Lado (Blue/Red) nas suas apostas para ver estatísticas avançadas.",
      style: TextStyle(color: Colors.white38),
      textAlign: TextAlign.center,
    ),
  );
}
