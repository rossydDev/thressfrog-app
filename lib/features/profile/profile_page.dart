import 'package:flutter/material.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  late InvestorProfile _selectedProfile;
  String _selectedAvatar = "🐸";

  // [NOVO] Estado local para o Ghost Mode
  bool _ghostModeEnabled = false;

  @override
  void initState() {
    super.initState();
    final user = BankrollController.instance.user;

    _nameController.text = user.name;
    _selectedProfile = user.profile;
    _ghostModeEnabled =
        user.ghostMode; // Carrega do usuário

    _updateAvatarFromProfile(_selectedProfile);
  }

  void _updateAvatarFromProfile(InvestorProfile profile) {
    if (profile == InvestorProfile.turtle) {
      _selectedAvatar = "🐢";
    } else if (profile == InvestorProfile.alligator) {
      _selectedAvatar = "🐊";
    } else {
      _selectedAvatar = "🐸";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PERFIL DO INVESTIDOR"),
        backgroundColor: AppColors.deepBlack,
      ),
      backgroundColor: AppColors.deepBlack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Avatar (Mantido igual)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceDark,
                  border: Border.all(
                    color: AppColors.neonGreen,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _selectedAvatar,
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 2. Nome (Mantido igual)
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nome de Invocador",
                labelStyle: TextStyle(
                  color: Colors.white54,
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: AppColors.neonGreen,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white10,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.neonGreen,
                  ),
                ),
                filled: true,
                fillColor: AppColors.surfaceDark,
              ),
            ),
            const SizedBox(height: 30),

            // 3. Seleção de Perfil (Mantido igual)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Estilo de Gestão",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              InvestorProfile.turtle,
              "Tartaruga",
              "🐢",
              "Stake: 1% | Seguro",
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              InvestorProfile.frog,
              "Sapo",
              "🐸",
              "Stake: 2.5% | Equilibrado",
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              InvestorProfile.alligator,
              "Jacaré",
              "🐊",
              "Stake: 5% | Arriscado",
            ),

            const SizedBox(height: 40),

            // [NOVO] 4. PROTOCOLO FANTASMA (Interruptor)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _ghostModeEnabled
                    ? AppColors.neonPurple.withValues(
                        alpha: 0.1,
                      )
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _ghostModeEnabled
                      ? AppColors.neonPurple
                      : Colors.white10,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.neonPurple,
                title: const Text(
                  "Protocolo Fantasma",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Trava o app se atingir 50% da meta diária. Proteção contra ganância.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                value: _ghostModeEnabled,
                onChanged: (val) =>
                    setState(() => _ghostModeEnabled = val),
                secondary: Icon(
                  Icons.policy,
                  color: _ghostModeEnabled
                      ? AppColors.neonPurple
                      : Colors.white24,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 5. Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: _saveProfile,
                child: const Text(
                  "SALVAR ALTERAÇÕES",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper _buildProfileOption mantido igual...
  Widget _buildProfileOption(
    InvestorProfile profile,
    String label,
    String emoji,
    String desc,
  ) {
    final isSelected = _selectedProfile == profile;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedProfile = profile;
        _updateAvatarFromProfile(profile);
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonGreen.withValues(alpha: 0.1)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.neonGreen
                : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.neonGreen
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.neonGreen,
              ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    final controller = BankrollController.instance;
    final currentUser = controller.user;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text,
      profile: _selectedProfile,
      ghostMode:
          _ghostModeEnabled, // [ATUALIZAÇÃO] Salvando o Ghost Mode
    );

    controller.updateUser(updatedUser);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil atualizado!"),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    }
  }
}
