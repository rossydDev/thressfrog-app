import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../home/home_page.dart';
import '../oracle/oracle_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // As páginas que o app vai alternar
  final List<Widget> _pages = [
    const HomePage(),
    const OraclePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo muda conforme a aba selecionada
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // BARRA DE NAVEGAÇÃO INFERIOR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white10),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: AppColors.deepBlack,
          selectedItemColor: AppColors.neonGreen,
          unselectedItemColor: Colors.white38,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Banca',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(
                Icons.auto_stories,
              ), // Ícone de livro pro Grimório
              label: 'Grimório',
            ),
          ],
        ),
      ),
    );
  }
}
