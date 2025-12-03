import 'package:flutter/material.dart';
import 'package:thressfrog_app/core/state/bankroll_controller.dart';
import 'package:thressfrog_app/features/create_bet/create_bet_page.dart';

import '../../core/theme/app_theme.dart';
import '../../models/bet_model.dart';

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
          appBar: AppBar(
            title: const Text('THRESSFROG'),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_rounded,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.grid_view_rounded),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: 20),

                // Seção 1: Saldo (Hero Section)
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
                    fontWeight: .bold,
                    letterSpacing: -1.0,
                  ),
                ),

                const SizedBox(height: 30),

                // Seção 2: Resumo Rápido (Card Horizontais)
                Row(
                  children: [
                    Expanded(
                      child: _buildSumaryCard(
                        "Lucro Hoje",
                        "+ R\$ ${profit.toStringAsFixed(2)}",
                        isPositive: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSumaryCard(
                        "Win Rate",
                        winRate,
                        isPositive: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // -- Seção 3: Histórico Recente
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    const Text(
                      "Últimos Pulos",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: .bold,
                      ),
                    ),
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

                //Lista de Apostas
                Expanded(
                  child: bets.isEmpty
                      ? Center(
                          child: Text(
                            "Nenhum pulo registrado. \nComece sua jornada!",
                            textAlign: .center,
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
                            return _buildBetTile(bet);
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton:
              FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateBetPage(),
                  ),
                ),
                backgroundColor: AppColors.neonGreen,
                icon: const Icon(
                  Icons.add,
                  color: AppColors.deepBlack,
                ),
                label: const Text(
                  "NOVO PULO",
                  style: TextStyle(
                    color: AppColors.deepBlack,
                    fontWeight: .bold,
                  ),
                ),
              ),
        );
      },
    );
  }
}

Widget _buildSumaryCard(
  String title,
  String value, {
  bool isPositive = true,
}) {
  return Container(
    padding: const .all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceDark,
      borderRadius: .circular(24),
    ),
    child: Column(
      crossAxisAlignment: .start,
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
            fontWeight: .bold,
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
      statusText = "+ R\$ ${bet.profit.toStringAsFixed(2)}";
      break;
    case BetResult.loss:
      statusColor = AppColors.errorRed;
      statusIcon = Icons.arrow_downward_rounded;
      statusText = "- R\$ ${bet.stake.toStringAsFixed(2)}";
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
    margin: const .only(bottom: 12),
    padding: const .all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceDark,
      borderRadius: .circular(20),
    ),
    child: Row(
      children: [
        //Icone circuloar
        Container(
          padding: const .all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            shape: .circle,
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
        ),
        //Informações da Partida
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
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

        //Valor (Lucro ou Prejuizo)
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: .bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
