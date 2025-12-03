import 'package:flutter/material.dart';
import 'package:thressfrog_app/core/state/bankroll_controller.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../home/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() =>
      _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankrollController = TextEditingController();

  // Perfil selecionado (Começa com o Sapo por padrão)
  InvestorProfile _selectedProfile = InvestorProfile.frog;

  void _finishOnboarding() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final initialBank = double.parse(
        _bankrollController.text.replaceAll(',', '.'),
      );

      final user = UserProfile(
        name: name,
        initialBankroll: initialBank,
        profile: _selectedProfile,
      );

      // Aqui vamos salvar no Controller (Vamos criar esse método jaja)
      BankrollController.instance.setUserProfile(user);

      // Navega para a Home sem poder voltar (Substitui a tela atual)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Bem-vindo ao\nThressFrog 🐸",
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Configure sua estratégia antes de começar.",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // INPUT: Nome
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                  ),
                  cursorColor: AppColors.neonGreen,
                  decoration: _inputDecoration(
                    "Como devo te chamar?",
                    Icons.person,
                  ),
                  validator: (v) => v!.isEmpty
                      ? "Diga seu nome, invocador."
                      : null,
                ),

                const SizedBox(height: 20),

                // INPUT: Banca Inicial
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
                  decoration: _inputDecoration(
                    "Banca Inicial (R\$)",
                    Icons.account_balance_wallet,
                  ),
                  validator: (v) => v!.isEmpty
                      ? "Quanto você tem na banca?"
                      : null,
                ),

                const SizedBox(height: 40),

                const Text(
                  "Escolha seu Estilo de Jogo",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // CARDS DE PERFIL
                _buildProfileCard(
                  profile: InvestorProfile.turtle,
                  title: "A Tartaruga 🐢",
                  subtitle: "Conservador (1%)",
                  description:
                      "Crescimento lento e seguro. Blindado contra bad runs.",
                ),
                const SizedBox(height: 12),
                _buildProfileCard(
                  profile: InvestorProfile.frog,
                  title: "O Sapo 🐸",
                  subtitle: "Moderado (2.5%)",
                  description:
                      "O equilíbrio perfeito. Pulos calculados.",
                ),
                const SizedBox(height: 12),
                _buildProfileCard(
                  profile: InvestorProfile.alligator,
                  title: "O Jacaré 🐊",
                  subtitle: "Agressivo (5%)",
                  description:
                      "Alto risco, alta recompensa. Para quem tem sangue frio.",
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishOnboarding,
                    child: const Text("COMEÇAR JORNADA"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper para os Cards de Seleção
  Widget _buildProfileCard({
    required InvestorProfile profile,
    required String title,
    required String subtitle,
    required String description,
  }) {
    final isSelected = _selectedProfile == profile;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProfile = profile;
        });
      },
      // Animação suave quando clica
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Fundo muda levemente
          color: isSelected
              ? AppColors.neonGreen.withValues(alpha: .05)
              : AppColors.surfaceDark,

          borderRadius: BorderRadius.circular(16),

          // Borda Neon brilhante se selecionado
          border: Border.all(
            color: isSelected
                ? AppColors.neonGreen
                : Colors.transparent,
            width: 2,
          ),

          // Sombra Neon (Glow Effect) opcional
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(
                      alpha: .2,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Ícone Customizado no lugar do Radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.neonGreen
                      : AppColors.textGrey,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.neonGreen
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.deepBlack,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.neonGreen
                          : AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textGrey.withValues(
                        alpha: 0.8,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(
  String label,
  IconData icon,
) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textGrey),
    prefixIcon: Icon(icon, color: AppColors.neonGreen),
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.errorRed,
      ),
    ),
  );
}
