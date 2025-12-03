import 'package:flutter/material.dart';

import '../../core/state/bankroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bet_model.dart';

class CreateBetPage extends StatefulWidget {
  const CreateBetPage({super.key});

  @override
  State<CreateBetPage> createState() =>
      _CreateBetPageState();
}

class _CreateBetPageState extends State<CreateBetPage> {
  final _formKey = GlobalKey<FormState>();

  final _matchController = TextEditingController();
  final _oddController = TextEditingController();
  final _stakeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillStake();
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

      // Cria o objeto Bet
      final newBet = Bet(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(),
        matchTitle: _matchController.text,
        date: DateTime.now(),
        stake: stake,
        odd: odd,
        result: BetResult.pending,
        notes: _notesController.text,
      );

      // Manda pro Controller
      BankrollController.instance.addBet(newBet);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pulo registrado! Boa sorte 🐸"),
          backgroundColor: AppColors.neonGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NOVO PULO"),
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

              _buildInput(
                label: "Partida (Ex: T1 vs Gen.G)",
                controller: _matchController,
                icon: Icons.gamepad_outlined,
              ),

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
                  child: const Text("REGISTRAR PULO"),
                ),
              ),
            ],
          ),
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
