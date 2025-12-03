import 'package:flutter/material.dart';
import 'package:thressfrog_app/core/state/bankroll_controller.dart';

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

      final newBet = Bet(
        id: DateTime.now().microsecondsSinceEpoch
            .toString(),
        matchTitle: _matchController.text,
        date: .now(),
        stake: stake,
        odd: odd,
        result: .pending,
        notes: _notesController.text,
      );

      BankrollController.instance.addBet(newBet);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pulo registrado com sucesso!"),
          backgroundColor: AppColors.neonGreen,
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
        padding: const .all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                "Detalhes da Partida",
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontWeight: .bold,
                ),
              ),
              const SizedBox(height: 16),

              //Input 1: Partida
              _buildInput(
                label: "Partida (Ex: Pain vs T1)",
                controller: _matchController,
                icon: Icons.gamepad_outlined,
              ),

              const SizedBox(height: 24),

              //Row para colocar ODD e valor lado a lado
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      label: "Odd",
                      controller: _oddController,
                      icon: Icons.trending_up,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildInput(
                      label: "Valor",
                      controller: _stakeController,
                      icon: Icons.attach_money,
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              //Input 3: Anotações
              _buildInput(
                label: "Anotações / Estratégia",
                controller: _notesController,
                icon: Icons.edit_note,
                maxLiner: 3,
                isRequired: false,
              ),

              const SizedBox(height: 40),

              // Botão de Salvar Gigante
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
}

Widget _buildInput({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  bool isNumber = false,
  bool isRequired = true,
  int maxLiner = 1,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: isNumber
        ? const .numberWithOptions(decimal: true)
        : .text,
    maxLines: maxLiner,
    style: const TextStyle(color: AppColors.textWhite),
    cursorColor: AppColors.neonGreen,

    validator: (value) {
      if (isRequired && (value == null || value.isEmpty)) {
        return 'Campo obrigatorio';
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
        borderRadius: .circular(16),
        borderSide: .none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: .circular(16),
        borderSide: const BorderSide(
          color: AppColors.neonGreen,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: .circular(16),
        borderSide: const BorderSide(
          color: AppColors.errorRed,
          width: 2,
        ),
      ),
    ),
  );
}
