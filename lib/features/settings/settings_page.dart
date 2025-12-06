import 'package:flutter/material.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _bankrollController = TextEditingController();

  double _stopWin = 0.05;
  double _stopLoss = 0.03;
  InvestorProfile _profile = InvestorProfile.frog;
  bool _ghostMode = false;

  @override
  void initState() {
    super.initState();
    final user = BankrollController.instance.userProfile;
    final currentBalance =
        BankrollController.instance.currentBalance;

    if (user != null) {
      _nameController.text = user.name;
      _stopWin = user.stopWinPercentage;
      _stopLoss = user.stopLossPercentage;
      _profile = user.profile;
      _ghostMode = user.ghostMode;
    }
    _bankrollController.text = currentBalance
        .toStringAsFixed(2);
  }

  void _saveSettings() {
    final currentProfile =
        BankrollController.instance.userProfile;
    final newBalance =
        double.tryParse(
          _bankrollController.text.replaceAll(',', '.'),
        ) ??
        BankrollController.instance.currentBalance;

    final updatedUser = UserProfile(
      name: _nameController.text,
      initialBankroll: newBalance,
      profile: _profile,
      stopWinPercentage: _stopWin,
      stopLossPercentage: _stopLoss,
      currentLevel: currentProfile?.currentLevel ?? 1,
      currentXP: currentProfile?.currentXP ?? 0.0,
      ghostMode: _ghostMode,
      ghostTriggerPercentage: 0.50,
    );

    BankrollController.instance.updateUserProfileAndBalance(
      updatedUser,
      newBalance,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Configurações atualizadas!"),
        backgroundColor: AppColors.neonGreen,
      ),
    );
  }

  // --- NOVO: Lógica de Reset ---
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          "Zerar Tudo?",
          style: TextStyle(color: AppColors.errorRed),
        ),
        content: const Text(
          "Isso apagará TODAS as suas apostas, resetará seu Nível e XP. Essa ação não pode ser desfeita.",
          style: TextStyle(color: AppColors.textWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              BankrollController.instance
                  .fullReset(); // Vamos criar este método
              Navigator.pop(ctx); // Fecha Dialog
              Navigator.pop(
                context,
              ); // Fecha Settings e volta pra Home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Sistema reiniciado com sucesso.",
                  ),
                  backgroundColor: AppColors.textGrey,
                ),
              );
            },
            child: const Text(
              "ZERAR",
              style: TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CONFIGURAÇÕES")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Perfil & Banca",
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              style: const TextStyle(
                color: AppColors.textWhite,
              ),
              cursorColor: AppColors.neonGreen,
              decoration: const InputDecoration(
                labelText: "Nome do Invocador",
                filled: true,
                fillColor: AppColors.surfaceDark,
                prefixIcon: Icon(
                  Icons.person,
                  color: AppColors.neonGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bankrollController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
              style: const TextStyle(
                color: AppColors.textWhite,
              ),
              cursorColor: AppColors.neonGreen,
              decoration: const InputDecoration(
                labelText: "Banca Atual (R\$)",
                filled: true,
                fillColor: AppColors.surfaceDark,
                prefixIcon: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.neonGreen,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dropdown Inteligente
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(4),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade700,
                    width: 1,
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<InvestorProfile>(
                  value: _profile,
                  dropdownColor: AppColors.surfaceDark,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.neonGreen,
                  ),
                  onChanged: (InvestorProfile? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _profile = newValue;
                        // Automação dos Sliders
                        _stopWin = UserProfile.defaultWin(
                          newValue,
                        );
                        _stopLoss = UserProfile.defaultLoss(
                          newValue,
                        );
                      });
                    }
                  },
                  items: InvestorProfile.values
                      .map<
                        DropdownMenuItem<InvestorProfile>
                      >((InvestorProfile value) {
                        String label;
                        String emoji;
                        switch (value) {
                          case InvestorProfile.turtle:
                            label = "Tartaruga";
                            emoji = "🐢";
                            break;
                          case InvestorProfile.frog:
                            label = "Sapo";
                            emoji = "🐸";
                            break;
                          case InvestorProfile.alligator:
                            label = "Jacaré";
                            emoji = "🐊";
                            break;
                        }
                        return DropdownMenuItem<
                          InvestorProfile
                        >(
                          value: value,
                          child: Row(
                            children: [
                              Text(
                                emoji,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(label),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _ghostMode
                      ? AppColors.neonGreen.withValues(
                          alpha: 0.5,
                        )
                      : Colors.white10,
                ),
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                activeThumbColor: AppColors.neonGreen,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: AppColors.deepBlack,
                title: Row(
                  children: [
                    const Text(
                      "Ghost Froq",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "👻",
                      style: TextStyle(
                        fontSize: 20,
                        shadows: _ghostMode
                            ? [
                                const BoxShadow(
                                  color:
                                      AppColors.neonGreen,
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    _ghostMode
                        ? "Ativo: Se atingir 50% da meta, o Stop Loss sobre para 0 x 0"
                        : "Inativo: Stop Loss fixo no valor definido abaixo",
                    style: TextStyle(
                      color: _ghostMode
                          ? Colors.white70
                          : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _ghostMode = value;
                  });
                },
                value: _ghostMode,
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Limites de Segurança",
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),
            _buildSlider(
              "Meta de Lucro (Stop Win)",
              _stopWin,
              (v) => setState(() => _stopWin = v),
              AppColors.neonGreen,
            ),

            const SizedBox(height: 24),
            _buildSlider(
              "Limite de Perda (Stop Loss)",
              _stopLoss,
              (v) => setState(() => _stopLoss = v),
              AppColors.errorRed,
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text("SALVAR ALTERAÇÕES"),
              ),
            ),

            const SizedBox(height: 24),

            // --- BOTÃO DE RESET (ZONA DE PERIGO) ---
            Center(
              child: TextButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(
                  Icons.delete_forever,
                  color: AppColors.errorRed,
                ),
                label: const Text(
                  "Resert da Conta?",
                  style: TextStyle(
                    color: AppColors.errorRed,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${(value * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.deepBlack,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: 0.01,
              max: 0.20,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
