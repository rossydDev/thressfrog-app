import 'package:flutter/material.dart';
import 'package:thressfrog_app/features/home/widgets/bankroll_chart.dart';
import 'package:thressfrog_app/features/home/widgets/threshold_app_bar.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bet_model.dart';
import '../create_bet/create_bet_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

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
                        child: const Text(
                          "Ver tudo",
                          style: TextStyle(
                            color: AppColors.neonGreen,
                          ),
                        ),
                      ),
                  ],
                ),

                Expanded(
                  child: bets.isEmpty
                      ? Center(
                          child: Text(
                            "Nenhum pulo registrado.\nComece sua jornada!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textGrey
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: bets.length,
                          itemBuilder: (context, index) {
                            final bet = bets[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showResolveOptions(
                                    context,
                                    bet,
                                  ),
                              child: _buildBetTile(bet),
                            );
                          },
                        ),
                ),
              ],
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

  void _showResolveOptions(BuildContext context, Bet bet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled:
          true, // Permite o menu crescer se precisar
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
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
              // Cabeçalho com o Título e Botão de Fechar discreto
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SEÇÃO 1: Definir Resultado (Só mostra se ainda estiver pendente)
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
                const SizedBox(height: 12),
                _buildActionBtnCompact(
                  label: "ANULADA / REEMBOLSO",
                  color: AppColors.textGrey,
                  icon: Icons.refresh,
                  onTap: () {
                    BankrollController.instance.resolveBet(
                      bet,
                      BetResult.voided,
                    );
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 24),
              ],

              // SEÇÃO 2: Gerenciamento (Editar / Excluir)
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
                  Navigator.pop(
                    context,
                  ); // Fecha o menu primeiro
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
                  // Confirmação antes de excluir
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor:
                          AppColors.surfaceDark,
                      title: const Text(
                        "Excluir Pulo?",
                        style: TextStyle(
                          color: AppColors.textWhite,
                        ),
                      ),
                      content: const Text(
                        "Isso devolverá o valor da aposta para sua banca e removerá o registro.",
                        style: TextStyle(
                          color: AppColors.textGrey,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(ctx),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            BankrollController.instance
                                .deleteBet(bet);
                            Navigator.pop(
                              ctx,
                            ); // Fecha Dialog
                            Navigator.pop(
                              context,
                            ); // Fecha BottomSheet
                          },
                          child: const Text(
                            "EXCLUIR",
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.bold,
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
  }

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: bet.result == BetResult.pending
            ? Border.all(
                color: AppColors.neonGreen.withValues(
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
                Text(
                  bet.matchTitle,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
