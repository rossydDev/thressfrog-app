import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/lol_champion_model.dart';
import 'champion_search_modal.dart';

class DraftSelector extends StatefulWidget {
  final Function(List<String>) onDraftChanged;
  final List<String>? initialDraft;

  // Parâmetros de customização
  final String label;
  final Color activeColor;

  const DraftSelector({
    super.key,
    required this.onDraftChanged,
    this.initialDraft,
    this.label = "Draft do Time",
    this.activeColor = AppColors.neonPurple,
  });

  @override
  State<DraftSelector> createState() =>
      _DraftSelectorState();
}

class _DraftSelectorState extends State<DraftSelector> {
  // Lista de objetos Campeão (para exibir imagem)
  late List<LoLChampion?> _selectedChampions;
  final List<String> _roles = [
    "TOP",
    "JUNGLE",
    "MID",
    "ADC",
    "SUPP",
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa vazio.
    // Nota: Para carregar o 'initialDraft' na edição, precisaríamos buscar
    // o objeto LoLChampion pelo ID string. Por enquanto, inicia vazio.
    _selectedChampions = List.filled(5, null);
  }

  void _openSelection(int index) async {
    // Abre o modal de busca
    final LoLChampion? result =
        await showModalBottomSheet<LoLChampion>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ChampionSearchModal(),
        );

    if (result != null) {
      setState(() {
        _selectedChampions[index] = result;
      });

      // Converte objetos para lista de IDs (Strings) e manda pro pai
      final draftNames = _selectedChampions
          .where((c) => c != null)
          .map((c) => c!.id)
          .toList();

      widget.onDraftChanged(draftNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.activeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final champion = _selectedChampions[index];
            final roleName = _roles[index];

            return GestureDetector(
              onTap: () => _openSelection(index),
              child: Column(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: champion != null
                            ? widget.activeColor
                            : Colors.white10,
                        width: champion != null ? 2 : 1,
                      ),
                      image: champion != null
                          ? DecorationImage(
                              image: NetworkImage(
                                champion.imageUrl,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: champion == null
                        ? Center(
                            child: Text(
                              roleName[0],
                              style: const TextStyle(
                                color: Colors.white24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    champion != null
                        ? champion.name
                        : roleName,
                    style: TextStyle(
                      color: champion != null
                          ? widget.activeColor
                          : Colors.white24,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
