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

  double _stopWin = 0.05;
  double _stopLoss = 0.03;
  InvestorProfile _profile = InvestorProfile.frog;

  @override
  void initState() {
    super.initState();
    final user = BankrollController.instance.userProfile;
    if (user != null) {
      _nameController.text = user.name;
      _stopWin = user.stopWinPercentage;
      _stopLoss = user.stopLossPercentage;
      _profile = user.profile;
    }
  }

  void _saveSettings() {
    final currentProfile =
        BankrollController.instance.userProfile;

    final updatedUser = UserProfile(
      name: _nameController.text,
      // Mantém a banca inicial original para não quebrar o histórico
      initialBankroll:
          currentProfile?.initialBankroll ?? 100.0,
      profile: _profile,
      stopWinPercentage: _stopWin,
      stopLossPercentage: _stopLoss,
    );

    BankrollController.instance.setUserProfile(updatedUser);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Estratégia atualizada!"),
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
              "Perfil",
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
              decoration: InputDecoration(
                labelText: "Nome do Invocador",
                labelStyle: const TextStyle(
                  color: AppColors.textGrey,
                ),
                filled: true,
                fillColor: AppColors.surfaceDark,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.neonGreen,
                  ),
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
              "Defina quando o ThressFrog deve te alertar para parar. Esses valores sobrescrevem o padrão do seu animal.",
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
              overlayColor: color.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: 0.01,
              max: 0.20, // Máximo 20% para segurança visual
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
