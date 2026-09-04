import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'main_screens.dart';
import 'map_screen.dart';
import 'routes_navigation_screen.dart';

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
    SmartRoutesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final isAdmin = controller.user?.role == 'admin';

    Widget? actionButton;
    if (_index <= 1) {
      actionButton = FloatingActionButton.small(
        heroTag: 'favorites-shortcut',
        tooltip: 'Mis favoritos',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
        ),
        child: const Icon(Icons.favorite_outline),
      );
    } else if (_index == 4 && isAdmin) {
      actionButton = FloatingActionButton.extended(
        heroTag: 'admin-sync-destinations',
        tooltip: 'Sincronizar catálogo turístico',
        onPressed: controller.busy
            ? null
            : () async {
                try {
                  await controller.seedRemoteDestinations();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${controller.destinations.length} destinos sincronizados con Firestore.',
                      ),
                    ),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        controller.lastError ??
                            'No se pudo sincronizar el catálogo de destinos.',
                      ),
                    ),
                  );
                }
              },
        icon: const Icon(Icons.cloud_sync_outlined),
        label: const Text('Sincronizar destinos'),
      );
    }

    return Scaffold(
      body: _pages[_index],
      floatingActionButton: actionButton,
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
