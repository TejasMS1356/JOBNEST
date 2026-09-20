import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';

/// Responsive shell: bottom navigation on phones, a rail on wide layouts.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final favoritesCount = context.watch<FavoritesProvider>().count;
    final destinations = [
      _Destination(
        icon: Icons.work_outline_rounded,
        selectedIcon: Icons.work_rounded,
        label: 'Jobs',
      ),
      _Destination(
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: 'Favorites',
        badge: favoritesCount,
      ),
    ];

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: _index == 0
          ? const HomeScreen(key: ValueKey('home'))
          : const FavoritesScreen(key: ValueKey('favorites')),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: _badged(d.icon, d.badge),
                        selectedIcon: _badged(d.selectedIcon, d.badge),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: _badged(d.icon, d.badge),
                  selectedIcon: _badged(d.selectedIcon, d.badge),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _badged(IconData icon, int badge) {
    if (badge <= 0) return Icon(icon);
    return Badge.count(count: badge, child: Icon(icon));
  }
}

class _Destination {
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badge;
}
