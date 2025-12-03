import 'package:flutter/material.dart';

class AppColors {
  static const Color neonGreen = Color(0xFFD4FF00);
  static const Color deepBlack = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8E8E93);
  static const Color errorRed = Color(0xFFFF453A);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepBlack,

      // Definição de Cores
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textWhite,
        onPrimary: AppColors
            .deepBlack, // Texto preto quando estiver em cima do verde
      ),

      // Tipografia Moderna (Estilo Financeiro/Gamer)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textGrey,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textWhite,
        ),
      ),

      // Cards Iguais à Referência (Sem borda, fundo sólido, muito arredondados)
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation:
            0, // Design flat moderno não usa sombra projetada, usa cor
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            24,
          ), // Curva bem acentuada
        ),
      ),

      // Botões "Pílula" (Pill Shape)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: AppColors.deepBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
