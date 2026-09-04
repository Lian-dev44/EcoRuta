import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/destination.dart';
import '../models/tour_route.dart';
import '../widgets/ecoruta_widgets.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeScreen(),
      ExploreScreen(),
      FavoritesScreen(),
      RoutesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
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
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final featured = controller.destinations.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoRuta'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Icon(
                controller.isRemoteBackend
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_off_outlined,
                color: controller.isRemoteBackend
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black45,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Hola, ${controller.user?.name ?? 'Explorador'} 👋',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              '¿Qué rincón de Nicaragua quieres descubrir hoy?',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66A34A)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Viaja mejor, conoce más',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Guarda destinos y crea recorridos personalizados.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.eco, color: Colors.white, size: 56),
                ],
              ),
            ),
            const SizedBox(height: 22),
            BackendBadge(
              remote: controller.isRemoteBackend,
              label: controller.backendLabel,
            ),
            const SizedBox(height: 22),
            Text(
              'Destinos destacados',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (featured.isEmpty)
              EmptyState(
                icon: Icons.travel_explore,
                title: 'Todavía no hay destinos',
                message: controller.isRemoteBackend
                    ? 'Carga los destinos iniciales desde Perfil para comenzar.'
                    : 'No se pudieron cargar los datos de demostración.',
              )
            else
              ...featured.map(
                (destination) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DestinationCard(
                    destination: destination,
                    favorite:
                        controller.favoriteIds.contains(destination.id),
                    onTap: () => _openDetail(context, destination),
                    onFavorite: () =>
                        _toggleFavorite(context, destination.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  String _category = 'Todas';

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final categories = <String>[
      'Todas',
      ...controller.destinations.map((e) => e.category).toSet().toList()..sort(),
    ];

    final visible = controller.destinations.where((destination) {
      final query = _query.toLowerCase();
      final matchesQuery =
          destination.name.toLowerCase().contains(query) ||
              destination.department.toLowerCase().contains(query) ||
              destination.municipality.toLowerCase().contains(query);
      final matchesCategory =
          _category == 'Todas' || destination.category == _category;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar destinos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Buscar destino, municipio o departamento',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = categories[index];
                return ChoiceChip(
                  label: Text(item),
                  selected: _category == item,
                  onSelected: (_) => setState(() => _category = item),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message: 'Prueba con otro término o categoría.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final destination = visible[index];
                      return DestinationCard(
                        destination: destination,
                        favorite:
                            controller.favoriteIds.contains(destination.id),
                        onTap: () => _openDetail(context, destination),
                        onFavorite: () =>
                            _toggleFavorite(context, destination.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final favorites = controller.destinations
        .where((d) => controller.favoriteIds.contains(d.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'Aún no tienes favoritos',
              message:
                  'Guarda destinos desde Inicio, Explorar o el detalle del lugar.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final destination = favorites[index];
                return DestinationCard(
                  destination: destination,
                  favorite: true,
                  onTap: () => _openDetail(context, destination),
                  onFavorite: () =>
                      _toggleFavorite(context, destination.id),
                );
              },
            ),
    );
  }
}

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

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
                  'Combina dos o más destinos para planificar un recorrido.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: controller.routes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final route = controller.routes[index];
                return _RouteCard(route: route);
              },
            ),
    );
  }
}

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final Set<String> _selected = {};

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selected.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos dos destinos.')),
      );
      return;
    }

    final controller = EcoRutaScope.of(context);
    try {
      await controller.createRoute(_name.text.trim(), _selected.toList());
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta guardada correctamente.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.lastError ?? 'No se pudo guardar la ruta.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear ruta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nombre de la ruta',
                hintText: 'Ej. Fin de semana volcánico',
                prefixIcon: Icon(Icons.edit_road_outlined),
              ),
              validator: (value) => (value?.trim().length ?? 0) < 3
                  ? 'Escribe un nombre para la ruta'
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Selecciona destinos',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...controller.destinations.map(
              (destination) => CheckboxListTile(
                value: _selected.contains(destination.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selected.add(destination.id);
                    } else {
                      _selected.remove(destination.id);
                    }
                  });
                },
                title: Text(destination.name),
                subtitle: Text(destination.department),
                secondary: Icon(iconForCategory(destination.category)),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: controller.busy ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Guardar ruta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const BrandMark(size: 72),
          const SizedBox(height: 18),
          Text(
            user?.name ?? 'Explorador',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Center(
            child: Chip(
              avatar: const Icon(Icons.verified_user_outlined, size: 18),
              label: Text('Rol: ${user?.role ?? 'usuario'}'),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    controller.isRemoteBackend
                        ? Icons.cloud_done_outlined
                        : Icons.phone_android_outlined,
                  ),
                  title: const Text('Backend'),
                  subtitle: Text(controller.backendLabel),
                ),
                ListTile(
                  leading: const Icon(Icons.travel_explore),
                  title: const Text('Destinos disponibles'),
                  trailing: Text('${controller.destinations.length}'),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('Favoritos guardados'),
                  trailing: Text('${controller.favoriteIds.length}'),
                ),
                ListTile(
                  leading: const Icon(Icons.route_outlined),
                  title: const Text('Rutas creadas'),
                  trailing: Text('${controller.routes.length}'),
                ),
              ],
            ),
          ),
          if (controller.isRemoteBackend &&
              controller.destinations.isEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: controller.busy
                  ? null
                  : () async {
                      try {
                        await controller.seedRemoteDestinations();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Destinos iniciales guardados en Firestore.',
                            ),
                          ),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              controller.lastError ??
                                  'No se pudieron cargar los destinos.',
                            ),
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Cargar destinos iniciales en Firestore'),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: controller.busy
                ? null
                : () async {
                    await controller.signOut();
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final favorite = controller.favoriteIds.contains(destination.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.name),
        actions: [
          IconButton(
            tooltip: favorite ? 'Quitar favorito' : 'Guardar favorito',
            onPressed: () => _toggleFavorite(context, destination.id),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC8E6C9), Color(0xFFE8F5E9)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              iconForCategory(destination.category),
              size: 86,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            destination.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(destination.category)),
              Chip(label: Text(destination.department)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            destination.description,
            style: const TextStyle(fontSize: 16, height: 1.55),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_city_outlined),
                  title: const Text('Municipio'),
                  subtitle: Text(destination.municipality),
                ),
                ListTile(
                  leading: const Icon(Icons.pin_drop_outlined),
                  title: const Text('Coordenadas'),
                  subtitle: Text(
                    '${destination.latitude.toStringAsFixed(4)}, '
                    '${destination.longitude.toStringAsFixed(4)}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _toggleFavorite(context, destination.id),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
            label: Text(
              favorite ? 'Quitar de favoritos' : 'Guardar en favoritos',
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final TourRoute route;

  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final names = route.destinationIds
        .map(
          (id) => controller.destinations
              .where((d) => d.id == id)
              .map((d) => d.name)
              .firstOrNull,
        )
        .whereType<String>()
        .toList();

    return Card(
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.route)),
        title: Text(
          route.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          names.isEmpty
              ? '${route.destinationIds.length} destinos'
              : names.join(' → '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text('${route.destinationIds.length}'),
      ),
    );
  }
}

Future<void> _toggleFavorite(
  BuildContext context,
  String destinationId,
) async {
  final controller = EcoRutaScope.of(context);
  try {
    await controller.toggleFavorite(destinationId);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.lastError ?? 'No se pudo actualizar el favorito.',
        ),
      ),
    );
  }
}

void _openDetail(BuildContext context, Destination destination) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DestinationDetailScreen(destination: destination),
    ),
  );
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
