import 'package:flutter/material.dart';
import 'package:thressfrog_app/features/home/widgets/bankroll_chart.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bet_model.dart';
import '../create_bet/create_bet_page.dart';
import '../profile/profile_page.dart'; // Import da Página de Perfil
import 'widgets/grimoire_resolution_modal.dart';

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
          // 1. APPBAR COM BOTÃO DE PERFIL
          appBar: AppBar(
            backgroundColor: AppColors.deepBlack,
            elevation: 0,
            title: Row(
              children: [
                const Icon(
                  Icons.analytics,
                  color: AppColors.neonGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  "THRESS FROG",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              // Botão para abrir o Perfil
              IconButton(
                tooltip: "Meu Perfil",
                icon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 2. SEÇÃO DE SALDO INTERATIVO (GERENCIAR CAPITAL)
                const Text(
                  "Banca Total",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                // GestureDetector para abrir o menu de capital ao clicar no saldo
                GestureDetector(
                  onTap: () =>
                      _showBankrollManager(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "R\$ ${bankroll.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Ícone discreto indicando edição
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: AppColors.neonGreen,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Cards de Resumo
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
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
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

                const SizedBox(height: 80),
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

  // --- 3. NOVO: GERENCIADOR DE BANCA (Depósito/Saque) ---
  void _showBankrollManager(BuildContext context) {
    final amountController = TextEditingController();

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
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Gerenciar Capital",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Faça um aporte ou realize seus lucros. Isso ajusta sua banca sem afetar as estatísticas de apostas.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: "R\$ ",
                  prefixStyle: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 24,
                  ),
                  hintText: "0.00",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.neonGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  // BOTÃO DEPOSITAR
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        final val = double.tryParse(
                          amountController.text.replaceAll(
                            ',',
                            '.',
                          ),
                        );
                        if (val != null && val > 0) {
                          // Chama o método updateCapital que criamos no controller
                          BankrollController.instance
                              .updateCapital(val);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Aporte de R\$ $val realizado! 🚀",
                              ),
                              backgroundColor:
                                  AppColors.neonGreen,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text("APORTAR"),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // BOTÃO SACAR
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.surfaceDark,
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(
                          color: AppColors.errorRed,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        final val = double.tryParse(
                          amountController.text.replaceAll(
                            ',',
                            '.',
                          ),
                        );
                        if (val != null && val > 0) {
                          // Chama o método updateCapital com valor negativo para sacar
                          BankrollController.instance
                              .updateCapital(-val);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Saque realizado. Dinheiro no bolso! 💸",
                              ),
                              backgroundColor: Colors.white,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_downward,
                      ),
                      label: const Text("SACAR"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- LOGICA DE RESOLUÇÃO (Mantida igual) ---

  void _showResolveOptions(BuildContext context, Bet bet) {
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
              // Cabeçalho do Modal
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

              // SE APOSTA PENDENTE -> MOSTRAR OPÇÕES DE RESOLUÇÃO
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
                    // BOTÃO GREEN
                    Expanded(
                      child: _buildActionBtnCompact(
                        label: "GREEN",
                        color: AppColors.neonGreen,
                        icon: Icons.trending_up,
                        onTap: () {
                          // Lógica Inteligente: É Grimório?
                          if (bet.myTeamDraft != null) {
                            Navigator.pop(
                              context,
                            ); // Fecha menu
                            // Abre Entrevista Pós-Jogo
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor:
                                  Colors.transparent,
                              builder: (ctx) =>
                                  GrimoireResolutionModal(
                                    bet: bet,
                                    intendedResult:
                                        BetResult.win,
                                  ),
                            );
                          } else {
                            // Aposta Simples: Resolve Direto
                            BankrollController.instance
                                .resolveBet(
                                  bet,
                                  BetResult.win,
                                );
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // BOTÃO RED
                    Expanded(
                      child: _buildActionBtnCompact(
                        label: "RED",
                        color: AppColors.errorRed,
                        icon: Icons.trending_down,
                        onTap: () {
                          // Mesma lógica para RED
                          if (bet.myTeamDraft != null) {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor:
                                  Colors.transparent,
                              builder: (ctx) =>
                                  GrimoireResolutionModal(
                                    bet: bet,
                                    intendedResult:
                                        BetResult.loss,
                                  ),
                            );
                          } else {
                            BankrollController.instance
                                .resolveBet(
                                  bet,
                                  BetResult.loss,
                                );
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _buildActionBtnCompact(
                  label: "ANULAR / REEMBOLSO",
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

              // GERENCIAMENTO (Editar/Excluir)
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
                      backgroundColor:
                          AppColors.surfaceDark,
                      title: const Text(
                        "Excluir Pulo?",
                        style: TextStyle(
                          color: AppColors.textWhite,
                        ),
                      ),
                      content: const Text(
                        "Isso removerá o registro e estornará o valor (se pendente).",
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
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            BankrollController.instance
                                .deleteBet(bet);
                            Navigator.pop(alertCtx);
                            Navigator.pop(context);
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
  }

  // --- HELPERS VISUAIS ---

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
