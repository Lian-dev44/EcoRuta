import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/destination.dart';
import '../models/tour_route.dart';
import '../widgets/ecoruta_widgets.dart';
import 'main_screens.dart' show CreateRouteScreen;
import 'map_screen.dart';

class SmartRoutesScreen extends StatelessWidget {
  const SmartRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis rutas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.destinations.isEmpty
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateRouteScreen(),
                  ),
                ),
        icon: const Icon(Icons.add_road),
        label: const Text('Nueva ruta'),
      ),
      body: controller.routes.isEmpty
          ? const EmptyState(
              icon: Icons.route_outlined,
              title: 'Crea tu primera ruta',
              message:
                  'Combina dos o más destinos y luego úsala directamente en el mapa.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: controller.routes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final route = controller.routes[index];
                return _UsableRouteCard(route: route);
              },
            ),
    );
  }
}

class _UsableRouteCard extends StatelessWidget {
  final TourRoute route;

  const _UsableRouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final stops = _resolveStops(route, controller.destinations);
    final missingCount = route.destinationIds.length - stops.length;

    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.route,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${route.destinationIds.length} destinos guardados',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (stops.isNotEmpty)
              Text(
                stops.map((destination) => destination.name).join('  →  '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.4),
              )
            else
              const Text(
                'Los destinos de esta ruta ya no están disponibles en el catálogo.',
                style: TextStyle(color: Colors.black54),
              ),
            if (missingCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$missingCount destino${missingCount == 1 ? '' : 's'} no disponible${missingCount == 1 ? '' : 's'} actualmente.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: stops.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MapScreen(
                              initialStops: stops,
                              routeName: route.name,
                            ),
                          ),
                        ),
                icon: const Icon(Icons.navigation),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Usar esta ruta en el mapa'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Destination> _resolveStops(
    TourRoute route,
    List<Destination> destinations,
  ) {
    final byId = {for (final destination in destinations) destination.id: destination};
    return route.destinationIds
        .map((id) => byId[id])
        .whereType<Destination>()
        .toList();
  }
}
