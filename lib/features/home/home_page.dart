import 'package:flutter/material.dart';
import 'package:thressfrog_app/features/home/widgets/bankroll_chart.dart';
import 'package:thressfrog_app/features/home/widgets/threshold_app_bar.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bet_model.dart';
import '../create_bet/create_bet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Roda assim que a tela nasce
  @override
  void initState() {
    super.initState();
    // Faz a sincronização silenciosa ao abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncData();
    });
  }

  // Método centralizado de sync
  Future<void> _syncData() async {
    final count = await BankrollController.instance
        .syncPendingBets();
    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$count apostas atualizadas pela API! 🐸✅",
          ),
          backgroundColor: AppColors.neonGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BankrollController.instance,
      builder: (context, child) {
        final controller = BankrollController.instance;
        final bets = controller.bets;
        final bankroll = controller.currentBalance;
        final winRate = controller.winRate;
        final profit = controller.todayProfit;

        return Scaffold(
          appBar: ThresholdAppBar(),
          body: RefreshIndicator(
            // [NOVIDADE] Puxar para atualizar (cor do loading)
            color: AppColors.neonGreen,
            backgroundColor: AppColors.surfaceDark,
            onRefresh: _syncData, // Chama o sync ao puxar
            child: SingleChildScrollView(
              // Physics necessário para o RefreshIndicator funcionar mesmo com pouco conteúdo
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Seção de Saldo (Sem o botão confuso agora)
                  const Text(
                    "Banca Total",
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "R\$ ${bankroll.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          "Lucro Total",
                          "R\$ ${profit.toStringAsFixed(2)}",
                          isPositive: profit >= 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          "Win Rate",
                          winRate,
                          isPositive: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const BankrollChart(),

                  const SizedBox(height: 30),

                  // Cabeçalho da Lista
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Últimos Pulos",
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bets.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Ver tudo (${bets.length})",
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Lista de Apostas
                  if (bets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          "Nenhum pulo registrado.\nComece sua jornada!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap:
                          true, // Importante dentro de SingleChildScrollView
                      physics:
                          const NeverScrollableScrollPhysics(), // Deixa o scroll pro pai
                      itemCount: bets.length,
                      itemBuilder: (context, index) {
                        final bet = bets[index];
                        return GestureDetector(
                          onTap: () => _showResolveOptions(
                            context,
                            bet,
                          ),
                          child: _buildBetTile(bet),
                        );
                      },
                    ),

                  const SizedBox(
                    height: 80,
                  ), // Espaço pro FAB
                ],
              ),
            ),
          ),
          floatingActionButton:
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CreateBetPage(),
                    ),
                  );
                },
                backgroundColor: AppColors.neonGreen,
                icon: const Icon(
                  Icons.add,
                  color: AppColors.deepBlack,
                ),
                label: const Text(
                  "NOVO PULO",
                  style: TextStyle(
                    color: AppColors.deepBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        );
      },
    );
  }

  // --- MÉTODOS VISUAIS ---

  void _showResolveOptions(BuildContext context, Bet bet) {
    final isOfficial = bet.pandaMatchId != null;

    // Usamos StatefulBuilder aqui para poder atualizar o estado DO MODAL
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        // Variável local para controlar o "Force Unlock"
        bool forceUnlock = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Lógica: Bloqueado se for Oficial E o usuário não clicou em forçar
            final isLocked = isOfficial && !forceUnlock;

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          bet.matchTitle,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textGrey,
                        ),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (bet.result == BetResult.pending) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "DEFINIR RESULTADO",
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isLocked) ...[
                      // --- CARTÃO DE BLOQUEIO ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.neonPurple
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.neonPurple
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.lock_clock,
                                  color:
                                      AppColors.neonPurple,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Aguardando API oficial...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Se a API falhar (Erro 403) ou demorar muito, você pode liberar manualmente abaixo.",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // [NOVO] Botão de Emergência
                            InkWell(
                              onTap: () {
                                setModalState(() {
                                  forceUnlock =
                                      true; // Libera a UI
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(
                                  8.0,
                                ),
                                child: Text(
                                  "LIBERAR EDIÇÃO MANUAL",
                                  style: TextStyle(
                                    color: AppColors
                                        .neonPurple,
                                    fontWeight:
                                        FontWeight.bold,
                                    decoration:
                                        TextDecoration
                                            .underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // --- BOTÕES LIBERADOS (Green/Red) ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionBtnCompact(
                              label: "GREEN",
                              color: AppColors.neonGreen,
                              icon: Icons.trending_up,
                              onTap: () {
                                BankrollController.instance
                                    .resolveBet(
                                      bet,
                                      BetResult.win,
                                    );
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionBtnCompact(
                              label: "RED",
                              color: AppColors.errorRed,
                              icon: Icons.trending_down,
                              onTap: () {
                                BankrollController.instance
                                    .resolveBet(
                                      bet,
                                      BetResult.loss,
                                    );
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    _buildActionBtnCompact(
                      label: "ANULAR / REEMBOLSO",
                      color: AppColors.textGrey,
                      icon: Icons.refresh,
                      onTap: () {
                        BankrollController.instance
                            .resolveBet(
                              bet,
                              BetResult.voided,
                            );
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Gerenciamento (Editar/Excluir)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "GERENCIAR",
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildActionBtnCompact(
                    label: "EDITAR INFORMAÇÕES",
                    color: Colors.blueAccent,
                    icon: Icons.edit,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateBetPage(betToEdit: bet),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionBtnCompact(
                    label: "EXCLUIR PULO",
                    color: Colors.red.shade900,
                    icon: Icons.delete_forever,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (alertCtx) => AlertDialog(
                          // Renomeei ctx para alertCtx
                          backgroundColor:
                              AppColors.surfaceDark,
                          title: const Text(
                            "Excluir Pulo?",
                            style: TextStyle(
                              color: AppColors.textWhite,
                            ),
                          ),
                          content: const Text(
                            "Isso removerá o registro.",
                            style: TextStyle(
                              color: AppColors.textGrey,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertCtx),
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(
                                  color:
                                      AppColors.textWhite,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                BankrollController.instance
                                    .deleteBet(bet);
                                Navigator.pop(
                                  alertCtx,
                                ); // Fecha o Alert
                                Navigator.pop(
                                  context,
                                ); // Fecha o BottomSheet
                              },
                              child: const Text(
                                "EXCLUIR",
                                style: TextStyle(
                                  color: AppColors.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helpers visuais (Botões e Cards) - Mesmos de antes
  Widget _buildActionBtnCompact({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: color.withValues(alpha: 0.3),
            ),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value, {
    bool isPositive = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isPositive
                  ? AppColors.neonGreen
                  : AppColors.errorRed,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetTile(Bet bet) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (bet.result) {
      case BetResult.win:
        statusColor = AppColors.neonGreen;
        statusIcon = Icons.arrow_outward_rounded;
        statusText =
            "+ R\$ ${bet.profit.toStringAsFixed(2)}";
        break;
      case BetResult.loss:
        statusColor = AppColors.errorRed;
        statusIcon = Icons.arrow_downward_rounded;
        statusText =
            "- R\$ ${bet.stake.toStringAsFixed(2)}";
        break;
      case BetResult.pending:
        statusColor = AppColors.textGrey;
        statusIcon = Icons.access_time_rounded;
        statusText = "Pendente";
        break;
      default:
        statusColor = AppColors.textGrey;
        statusIcon = Icons.block;
        statusText = "Anulada";
    }

    final isOfficial = bet.pandaMatchId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: bet.result == BetResult.pending
            ? Border.all(
                color: isOfficial
                    ? AppColors.neonPurple.withValues(
                        alpha: 0.5,
                      )
                    : AppColors.neonGreen.withValues(
                        alpha: 0.3,
                      ),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        bet.matchTitle,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOfficial) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: AppColors.neonPurple,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                Text(
                  "Odd: ${bet.odd}",
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
