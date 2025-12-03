import 'package:flutter/material.dart';
import 'package:thressfrog_app/features/home/home_page.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const ThressFrogApp());
}

class ThressFrogApp extends StatelessWidget {
  const ThressFrogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ThressFrog",
      debugShowCheckedModeBanner: false,

      theme: AppTheme.darkTheme,

      home: const Scaffold(body: Center(child: HomePage())),
    );
  }
}

// Widget temporario só para visualizar a paleta de cores
