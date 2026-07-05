import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_colors.dart';
import 'camera_screen.dart';
import 'family_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;

    final pages = const [
      HomeScreen(),
      HistoryScreen(),
      FamilyScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index == 0
          ? _PulsingFab(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CameraScreen())),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: strings.get('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            selectedIcon: const Icon(Icons.history, color: AppColors.primary),
            label: strings.get('history'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people, color: AppColors.primary),
            label: strings.get('family'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings, color: AppColors.primary),
            label: strings.get('settings'),
          ),
        ],
      ),
    );
  }
}

class _PulsingFab extends StatefulWidget {
  const _PulsingFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_PulsingFab> createState() => _PulsingFabState();
}

class _PulsingFabState extends State<_PulsingFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 1.0,
        end: 1.08,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        shape: const CircleBorder(),
        child: const Icon(Icons.document_scanner_outlined),
      ),
    );
  }
}
