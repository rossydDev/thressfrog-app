import 'package:flutter/material.dart';

import '../../../core/data/team_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/lol_team_model.dart';

// [CORREÇÃO] Removemos o <LoLTeam?> para evitar conflito de tipos estritos.
// O Flutter vai tratar como dynamic, o que resolve o erro de atribuição.
class TeamSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel =>
      "Buscar Time (Ex: Pain, T1)";

  @override
  TextStyle? get searchFieldStyle =>
      const TextStyle(color: Colors.white, fontSize: 18);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
        iconTheme: const IconThemeData(
          color: AppColors.neonGreen,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Retorna null ao cancelar
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return _buildMessage(
        "Digite pelo menos 3 letras...",
        Icons.keyboard,
      );
    }

    return FutureBuilder<List<LoLTeam>>(
      future: TeamRepository.instance.searchOnline(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.neonGreen,
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildMessage(
            "Erro na conexão com o Oráculo.",
            Icons.error_outline,
          );
        }

        final teams = snapshot.data ?? [];

        if (teams.isEmpty) {
          return _buildMessage(
            "Nenhum time encontrado nas sombras.",
            Icons.search_off,
          );
        }

        return ListView.separated(
          itemCount: teams.length,
          separatorBuilder: (_, __) => const Divider(
            color: Colors.white10,
            height: 1,
          ),
          itemBuilder: (context, index) {
            final team = teams[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: team.logoUrl.isNotEmpty
                    ? Image.network(
                        team.logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(
                              Icons.shield,
                              color: Colors.white24,
                            ),
                      )
                    : const Icon(
                        Icons.shield,
                        color: Colors.white24,
                      ),
              ),
              title: Text(
                team.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                team.acronym,
                style: const TextStyle(
                  color: AppColors.neonGreen,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.white24,
              ),
              onTap: () {
                close(
                  context,
                  team,
                ); // Retorna o time (dynamic que será convertido)
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildMessage(
      "Busque por times globais...",
      Icons.public,
    );
  }

  Widget _buildMessage(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(color: Colors.white30),
          ),
        ],
      ),
    );
  }
}
