import 'package:flutter/material.dart';
import 'package:graph_app/screens/saved_graphs/saved_graphs_screen.dart';
import 'package:graph_app/theme/app_palette.dart';
import 'package:graph_app/theme/theme_builder.dart';

import 'home_app_bar.dart';
import 'home_bottom_nav.dart';
import 'home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, isDark) {
        final palette = AppPalette(isDark);
        final onHome = _currentIndex == 0;

        return Scaffold(
          backgroundColor: palette.background,
          appBar: onHome ? HomeAppBar(palette: palette) : null,
          body: onHome
              ? HomeContent(palette: palette)
              : const SavedGraphsScreen(),
          bottomNavigationBar: HomeBottomNav(
            palette: palette,
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
        );
      },
    );
  }
}
