import 'package:flutter/material.dart';

import '../../../core/services/champion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/lol_champion_model.dart';

class ChampionSearchModal extends StatefulWidget {
  const ChampionSearchModal({super.key});

  @override
  State<ChampionSearchModal> createState() =>
      _ChampionSearchModalState();
}

class _ChampionSearchModalState
    extends State<ChampionSearchModal> {
  final _championService = ChampionService();
  final _searchController = TextEditingController();

  List<LoLChampion> _allChampions = [];
  List<LoLChampion> _filteredChampions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChampions();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadChampions() async {
    final list = await _championService.getChampions();
    if (mounted) {
      setState(() {
        _allChampions = list;
        _filteredChampions = list;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChampions = _allChampions.where((champ) {
        return champ.name.toLowerCase().contains(query) ||
            champ.id.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.85, // Ocupa 85% da tela
      decoration: const BoxDecoration(
        color: AppColors.deepBlack,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Barra de Arrastar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Campo de Busca
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar Campeão (Ex: Ahri)",
                hintStyle: const TextStyle(
                  color: Colors.white38,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.neonGreen,
                ),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Lista de Campeões
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.neonGreen,
                    ),
                  )
                : _filteredChampions.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum campeão encontrado",
                      style: TextStyle(
                        color: Colors.white38,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 4 Colunas
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              0.8, // Altura um pouco maior que a largura para caber o nome
                        ),
                    itemCount: _filteredChampions.length,
                    itemBuilder: (context, index) {
                      final champ =
                          _filteredChampions[index];
                      return GestureDetector(
                        onTap: () {
                          // Retorna o Campeão Selecionado
                          Navigator.pop(context, champ);
                        },
                        child: Column(
                          children: [
                            // Avatar Redondo
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white10,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      champ.imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              champ.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
