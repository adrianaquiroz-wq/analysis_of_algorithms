import 'package:flutter/material.dart';
import 'package:graph_app/theme/app_palette.dart';

class HomeBottomNav extends StatelessWidget {
  final AppPalette palette;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.palette,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: palette.card,
      selectedItemColor: palette.accent,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
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
