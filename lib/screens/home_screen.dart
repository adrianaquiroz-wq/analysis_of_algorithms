import 'package:flutter/material.dart';

import 'help_screen.dart';
import 'saved_graphs_screen.dart';
import 'graph_screen.dart';
import 'home/category_cards.dart';
import 'home/intro_section.dart';
import 'home/team_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = true;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final appBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final accentColor = isDarkMode ? Colors.cyanAccent : Colors.blueAccent;

    if (_currentIndex == 1) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SavedGraphsScreen(
          isDarkMode: isDarkMode,
          onToggleTheme: (val) => setState(() => isDarkMode = val),
        ),
        bottomNavigationBar: _buildBottomNav(accentColor, cardColor),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(appBarColor, textColor, accentColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'ANÁLISIS DE ALGORITMOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            IntroSection(
              isDarkMode: isDarkMode,
              textColor: textColor,
              cardColor: cardColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 24),
            TeamSection(
              isDarkMode: isDarkMode,
              textColor: textColor,
              cardColor: cardColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Módulos y Algoritmos',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GraphsCategoryCard(
              isDarkMode: isDarkMode,
              textColor: textColor,
              cardColor: cardColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            SortingCategoryCard(
              isDarkMode: isDarkMode,
              textColor: textColor,
              cardColor: cardColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 30),
            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.edit_note_rounded, color: accentColor),
                label: Text(
                  'Abrir Lienzo Libre de Grafos',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GraphScreen(
                        initialBipartiteAssignment: false,
                        algorithmType: 'free',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(accentColor, cardColor),
    );
  }

  PreferredSizeWidget _buildAppBar(
    Color appBarColor,
    Color textColor,
    Color accentColor,
  ) {
    return AppBar(
      backgroundColor: appBarColor,
      elevation: 1,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome, color: accentColor, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'ST-GR / Graph Suite',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: accentColor,
          ),
          onPressed: () => setState(() => isDarkMode = !isDarkMode),
          tooltip: 'Cambiar tema',
        ),
        IconButton(
          icon: Icon(Icons.help_outline_rounded, color: accentColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HelpScreen(isDarkMode: isDarkMode),
              ),
            );
          },
          tooltip: 'Ayuda',
        ),
      ],
    );
  }

  Widget _buildBottomNav(Color accentColor, Color cardColor) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      backgroundColor: cardColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_shared_rounded),
          label: 'Archivos Guardados',
        ),
      ],
    );
  }
}
