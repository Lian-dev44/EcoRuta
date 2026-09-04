import 'package:flutter/material.dart';

import 'main_screens.dart';
import 'map_screen.dart';

class EcoRutaMainShell extends StatefulWidget {
  const EcoRutaMainShell({super.key});

  @override
  State<EcoRutaMainShell> createState() => _EcoRutaMainShellState();
}

class _EcoRutaMainShellState extends State<EcoRutaMainShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    ExploreScreen(),
    MapScreen(),
    RoutesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      floatingActionButton: _index <= 1
          ? FloatingActionButton.small(
              heroTag: 'favorites-shortcut',
              tooltip: 'Mis favoritos',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
              child: const Icon(Icons.favorite_outline),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Rutas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
