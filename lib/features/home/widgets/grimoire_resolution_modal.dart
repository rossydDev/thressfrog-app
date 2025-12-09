import 'package:flutter/material.dart';

import '../../../core/state/bankroll_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/bet_model.dart';

class GrimoireResolutionModal extends StatefulWidget {
  final Bet bet;
  final BetResult intendedResult;

  const GrimoireResolutionModal({
    super.key,
    required this.bet,
    required this.intendedResult,
  });

  @override
  State<GrimoireResolutionModal> createState() =>
      _GrimoireResolutionModalState();
}

class _GrimoireResolutionModalState
    extends State<GrimoireResolutionModal> {
  double _towers = 0;
  double _dragons = 0;
  double _barons = 0;

  // [MUDANÇA] Usamos inteiros diretos agora, com valores padrão de "Linha Média" do LoL
  int _totalKills = 26; // Média comum de linha
  int _duration = 32; // Média comum de tempo

  @override
  void initState() {
    super.initState();
    // Carrega dados existentes ou usa os padrões
    _towers = (widget.bet.towers ?? 0).toDouble();
    _dragons = (widget.bet.dragons ?? 0).toDouble();
    _barons = (widget.bet.baronNashors ?? 0).toDouble();

    if (widget.bet.totalMatchKills != null) {
      _totalKills = widget.bet.totalMatchKills!;
    }
    if (widget.bet.matchDuration != null) {
      _duration = widget.bet.matchDuration!;
    }
  }

  void _confirmResolution() {
    final statsBet = widget.bet.copyWith(
      towers: _towers.toInt(),
      dragons: _dragons.toInt(),
      baronNashors: _barons.toInt(),
      totalMatchKills: _totalKills,
      matchDuration: _duration,
    );

    BankrollController.instance.updateBet(
      widget.bet,
      statsBet,
    );
    BankrollController.instance.resolveBet(
      statsBet,
      widget.intendedResult,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Dados do Grimório registrados! 🐸📚",
        ),
        backgroundColor: AppColors.neonPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.intendedResult == BetResult.win;
    final color = isWin
        ? AppColors.neonGreen
        : AppColors.errorRed;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: color, width: 3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWin
                    ? Icons.emoji_events
                    : Icons.thumb_down,
                color: color,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    isWin
                        ? "GREEN! O QUE ROLOU?"
                        : "RED. VAMOS ANALISAR.",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    "Ajuste os valores finais da partida.",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // --- OBJETIVOS (Sliders) ---
          // Mantive os sliders para objetivos pequenos (0-11) pois é rápido
          _buildSlider(
            "Torres (Seu Time)",
            _towers,
            11,
            AppColors.neonPurple,
            (v) => setState(() => _towers = v),
          ),
          _buildSlider(
            "Dragões",
            _dragons,
            5,
            Colors.orangeAccent,
            (v) => setState(() => _dragons = v),
          ),
          _buildSlider(
            "Barões",
            _barons,
            3,
            Colors.blueAccent,
            (v) => setState(() => _barons = v),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),

          // --- ESTILO CASA DE APOSTA (Linhas) ---
          Row(
            children: [
              Expanded(
                child: _buildBettingLineInput(
                  label: "Total Kills",
                  value: _totalKills,
                  onChanged: (val) =>
                      setState(() => _totalKills = val),
                  color: Colors
                      .redAccent, // Kills = Sangue/Agressividade
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildBettingLineInput(
                  label: "Duração (Min)",
                  value: _duration,
                  onChanged: (val) =>
                      setState(() => _duration = val),
                  color:
                      Colors.tealAccent, // Tempo = Relógio
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.deepBlack,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _confirmResolution,
              child: const Text(
                "CONFIRMAR RESULTADO",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                context,
              ).viewInsets.bottom,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET NOVO: Visual de "Linha de Aposta" ---
  Widget _buildBettingLineInput({
    required String label,
    required int value,
    required Function(int) onChanged,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              // Botão Menos
              _buildIconButton(Icons.remove, () {
                if (value > 0) onChanged(value - 1);
              }),

              // O Valor (Parece a Odd/Linha)
              Text(
                value.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              // Botão Mais
              _buildIconButton(
                Icons.add,
                () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 50,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white38, size: 18),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double max,
    Color color,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 12,
            ),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: max,
            divisions: max.toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
