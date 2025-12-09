import 'package:flutter/material.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bet_model.dart';
import '../../models/lol_match_model.dart';
import '../create_bet/select_match_screen.dart';

class CreateBetPage extends StatefulWidget {
  final Bet? betToEdit;

  const CreateBetPage({super.key, this.betToEdit});

  @override
  State<CreateBetPage> createState() =>
      _CreateBetPageState();
}

class _CreateBetPageState extends State<CreateBetPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _matchController;
  late TextEditingController _oddController;
  late TextEditingController _stakeController;
  late TextEditingController _notesController;

  // Variáveis para controlar a escolha via API
  LoLMatch? _selectedApiMatch;
  int? _selectedTeamId;

  // [NOVO] Variável para controlar o Lado (Side)
  LoLSide? _selectedSide;

  @override
  void initState() {
    super.initState();
    _matchController = TextEditingController(
      text: widget.betToEdit?.matchTitle ?? '',
    );
    _oddController = TextEditingController(
      text: widget.betToEdit?.odd.toString() ?? '',
    );
    _stakeController = TextEditingController(
      text: widget.betToEdit?.stake.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.betToEdit?.notes ?? '',
    );

    // Carrega dados existentes se for edição
    if (widget.betToEdit != null) {
      _selectedTeamId = widget.betToEdit!.pickedTeamId;
      _selectedSide =
          widget.betToEdit!.side; // [NOVO] Carrega o lado
      // Nota: Não carregamos _selectedApiMatch completo na edição simples
      // pois não salvamos o objeto todo, apenas o ID.
    } else {
      _prefillStake();
    }
  }

  void _prefillStake() {
    final controller = BankrollController.instance;
    final user = controller.userProfile;
    final currentBank = controller.currentBalance;
    if (user != null) {
      final suggestedValue = user.suggestedStake(
        currentBank,
      );
      _stakeController.text = suggestedValue
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _matchController.dispose();
    _oddController.dispose();
    _stakeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final stake = double.parse(
        _stakeController.text.replaceAll(',', '.'),
      );
      final odd = double.parse(
        _oddController.text.replaceAll(',', '.'),
      );

      final currentBalance =
          BankrollController.instance.currentBalance;
      double availableFunds = currentBalance;
      if (widget.betToEdit != null) {
        availableFunds += widget.betToEdit!.stake;
      }

      if (stake > availableFunds) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Saldo insuficiente! Você tem apenas R\$ ${availableFunds.toStringAsFixed(2)}",
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      final isEditing = widget.betToEdit != null;

      final newBet = Bet(
        id: isEditing
            ? widget.betToEdit!.id
            : DateTime.now().millisecondsSinceEpoch
                  .toString(),
        matchTitle: _matchController.text,
        date: isEditing
            ? widget.betToEdit!.date
            : DateTime.now(),
        stake: stake,
        odd: odd,
        result: isEditing
            ? widget.betToEdit!.result
            : BetResult.pending,
        notes: _notesController.text,

        // Dados de Inteligência
        pandaMatchId:
            _selectedApiMatch?.id ??
            widget.betToEdit?.pandaMatchId,
        pickedTeamId: _selectedTeamId,
        side:
            _selectedSide, // [NOVO] Salvando o lado escolhido
      );

      if (isEditing) {
        BankrollController.instance.updateBet(
          widget.betToEdit!,
          newBet,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pulo corrigido!"),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      } else {
        final xpResult = BankrollController.instance.addBet(
          newBet,
        );
        Navigator.pop(context);

        if (xpResult.leveledUp) {
          _showLevelUpDialog(context);
        } else if (xpResult.gainedXP) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.verified,
                    color: AppColors.deepBlack,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Pulo registrado! +${xpResult.xpAmount} XP por disciplina 🐸",
                  ),
                ],
              ),
              backgroundColor: AppColors.neonGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Pulo registrado (Sem XP: Fora da gestão)",
              ),
              backgroundColor: AppColors.textGrey,
            ),
          );
        }
      }
    }
  }

  void _showLevelUpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: AppColors.neonGreen,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(
                  alpha: .1,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.neonGreen,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "LEVEL UP!",
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 32,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Sua disciplina compensou. Você evoluiu e está mais perto de se tornar um Sapo Rei.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("CONTINUAR JORNADA"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.betToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "EDITAR PULO" : "NOVO PULO",
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detalhes da Partida",
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (!isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final match =
                          await Navigator.push<LoLMatch>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SelectMatchScreen(),
                            ),
                          );

                      if (match != null) {
                        setState(() {
                          _selectedApiMatch = match;
                          _matchController.text =
                              match.name;
                          _selectedTeamId = null;
                          _selectedSide =
                              null; // Reseta side ao trocar partida
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.neonGreen,
                    ),
                    label: const Text(
                      "Buscar Jogo Oficial (LoL)",
                      style: TextStyle(
                        color: AppColors.neonGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.neonGreen,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _buildInput(
                label: "Partida (Ex: T1 vs Gen.G)",
                controller: _matchController,
                icon: Icons.gamepad_outlined,
              ),

              // --- SELETOR DE TIMES ---
              if (_selectedApiMatch != null &&
                  _selectedApiMatch!.teamA != null &&
                  _selectedApiMatch!.teamB != null) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "Em quem você vai apostar?",
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTeamSelector(
                      _selectedApiMatch!.teamA!,
                      _selectedTeamId ==
                          _selectedApiMatch!.teamA!.id,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "VS",
                      style: TextStyle(
                        color: Colors.white24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildTeamSelector(
                      _selectedApiMatch!.teamB!,
                      _selectedTeamId ==
                          _selectedApiMatch!.teamB!.id,
                    ),
                  ],
                ),
              ],

              // --- [NOVO] SELETOR DE LADO (SIDE) ---
              const SizedBox(height: 24),
              const Text(
                "Configuração Tática (Opcional)",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSideSelector(
                      LoLSide.blue,
                      "Blue Side",
                      Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSideSelector(
                      LoLSide.red,
                      "Red Side",
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),

              // -------------------------------------
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      label: "Odd (Cotação)",
                      controller: _oddController,
                      icon: Icons.trending_up,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInput(
                      label: "Valor (Stake)",
                      controller: _stakeController,
                      icon: Icons.attach_money,
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildInput(
                label: "Anotações / Estratégia",
                controller: _notesController,
                icon: Icons.edit_note,
                maxLines: 3,
                isRequired: false,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    isEditing
                        ? "SALVAR ALTERAÇÕES"
                        : "REGISTRAR PULO",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para desenhar o cartão do time
  Widget _buildTeamSelector(Team team, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTeamId = team.id;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonGreen.withValues(alpha: 0.1)
                : AppColors.surfaceDark,
            border: Border.all(
              color: isSelected
                  ? AppColors.neonGreen
                  : Colors.white10,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              if (team.logoUrl != null)
                Image.network(
                  team.logoUrl!,
                  height: 50,
                  width: 50,
                )
              else
                const Icon(
                  Icons.shield,
                  color: Colors.white24,
                  size: 40,
                ),
              const SizedBox(height: 12),
              Text(
                team.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.neonGreen
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [NOVO] Widget para selecionar o lado
  Widget _buildSideSelector(
    LoLSide side,
    String label,
    Color color,
  ) {
    final isSelected = _selectedSide == side;
    return GestureDetector(
      onTap: () {
        setState(() {
          // Se já estiver selecionado, desmarca (toggle)
          if (_selectedSide == side) {
            _selectedSide = null;
          } else {
            _selectedSide = side;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppColors.surfaceDark,
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bolinha colorida
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color,
                          blurRadius: 6,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white38,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(
              decimal: true,
            )
          : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textWhite),
      cursorColor: AppColors.neonGreen,
      validator: (value) {
        if (isRequired &&
            (value == null || value.isEmpty)) {
          return 'Campo obrigatório';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textGrey,
        ),
        prefixIcon: Icon(icon, color: AppColors.neonGreen),
        filled: true,
        fillColor: AppColors.surfaceDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.neonGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1,
          ),
        ),
      ),
    );
  }
}
