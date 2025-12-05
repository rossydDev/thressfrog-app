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
  final _bankrollController =
      TextEditingController(); // Novo controller para banca

  double _stopWin = 0.05;
  double _stopLoss = 0.03;
  InvestorProfile _profile = InvestorProfile.frog;

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
    }
    // Preenche a banca atual
    _bankrollController.text = currentBalance
        .toStringAsFixed(2);
  }

  void _saveSettings() {
    final currentProfile =
        BankrollController.instance.userProfile;

    // Pega o novo valor da banca (com validação básica)
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
    );

    // Salva o perfil e atualiza a banca no controller
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

            // Input Nome
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

            // Input Banca (Novo)
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
                helperText:
                    "Use para ajustar saques ou depósitos.",
                helperStyle: TextStyle(
                  color: AppColors.textGrey,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dropdown de Perfil (Novo)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(
                  4,
                ), // Borda padrão do input decoration
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade700,
                    width: 1,
                  ),
                ), // Estilo underline padrão
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
                        // Opcional: Atualizar sliders com o padrão do novo perfil?
                        // _stopWin = UserProfile._defaultWin(newValue); // Método privado, teria que expor
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
                            label =
                                "Tartaruga (Conservador)";
                            emoji = "🐢";
                            break;
                          case InvestorProfile.frog:
                            label = "Sapo (Moderado)";
                            emoji = "🐸";
                            break;
                          case InvestorProfile.alligator:
                            label = "Jacaré (Agressivo)";
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

            const SizedBox(height: 32),
            const Text(
              "Limites de Segurança",
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ajuste seus limites manualmente se desejar.",
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
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
              overlayColor: color.withOpacity(0.2),
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
