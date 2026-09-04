import 'package:flutter/material.dart';

void main() {
  runApp(const EcoRutaApp());
}

class EcoRutaApp extends StatefulWidget {
  const EcoRutaApp({super.key});

  @override
  State<EcoRutaApp> createState() => _EcoRutaAppState();
}

class _EcoRutaAppState extends State<EcoRutaApp> {
  final AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return EcoRutaScope(
      notifier: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoRuta',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
          scaffoldBackgroundColor: const Color(0xFFF7F9F6),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE1E7E0)),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class EcoRutaScope extends InheritedNotifier<AppState> {
  const EcoRutaScope({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EcoRutaScope>();
    assert(scope != null, 'EcoRutaScope no encontrado');
    return scope!.notifier!;
  }
}

class AppState extends ChangeNotifier {
  bool loggedIn = false;
  String userName = 'Explorador';
  final Set<String> favoriteIds = <String>{'masaya'};
  final List<TourRoute> routes = <TourRoute>[];

  final List<Destination> destinations = const [
    Destination(
      id: 'masaya',
      name: 'Volcán Masaya',
      department: 'Masaya',
      category: 'Naturaleza',
      description: 'Uno de los destinos volcánicos más emblemáticos de Nicaragua, con miradores y paisajes únicos.',
      icon: Icons.terrain,
    ),
    Destination(
      id: 'granada',
      name: 'Centro histórico de Granada',
      department: 'Granada',
      category: 'Cultura',
      description: 'Arquitectura colonial, parques, iglesias y una amplia oferta cultural junto al Lago Cocibolca.',
      icon: Icons.account_balance,
    ),
    Destination(
      id: 'san_juan',
      name: 'San Juan del Sur',
      department: 'Rivas',
      category: 'Playa',
      description: 'Bahía del Pacífico conocida por sus atardeceres, actividades acuáticas y ambiente turístico.',
      icon: Icons.beach_access,
    ),
    Destination(
      id: 'ometepe',
      name: 'Isla de Ometepe',
      department: 'Rivas',
      category: 'Aventura',
      description: 'Isla formada por los volcanes Concepción y Maderas, ideal para senderismo y naturaleza.',
      icon: Icons.hiking,
    ),
    Destination(
      id: 'leon',
      name: 'Catedral de León',
      department: 'León',
      category: 'Historia',
      description: 'Monumento histórico y religioso ubicado en el corazón de León, con una destacada arquitectura.',
      icon: Icons.church,
    ),
  ];

  void login(String email) {
    loggedIn = true;
    final raw = email.split('@').first.trim();
    userName = raw.isEmpty ? 'Explorador' : _capitalize(raw);
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (!favoriteIds.add(id)) {
      favoriteIds.remove(id);
    }
    notifyListeners();
  }

  void addRoute(String name, List<String> destinationIds) {
    routes.add(
      TourRoute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        destinationIds: destinationIds,
      ),
    );
    notifyListeners();
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class Destination {
  final String id;
  final String name;
  final String department;
  final String category;
  final String description;
  final IconData icon;

  const Destination({
    required this.id,
    required this.name,
    required this.department,
    required this.category,
    required this.description,
    required this.icon,
  });
}

class TourRoute {
  final String id;
  final String name;
  final List<String> destinationIds;

  const TourRoute({required this.id, required this.name, required this.destinationIds});
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = EcoRutaScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: appState.loggedIn
          ? const MainShell(key: ValueKey('main'))
          : const LoginScreen(key: ValueKey('login')),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'usuario@ecoruta.app');
  final passwordController = TextEditingController(text: '123456');
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (formKey.currentState?.validate() != true) return;
    EcoRutaScope.of(context).login(emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandMark(size: 88),
                    const SizedBox(height: 20),
                    Text(
                      'Descubre Nicaragua\ncon EcoRuta',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora destinos, guarda favoritos y organiza tus recorridos.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty || !text.contains('@')) return 'Ingresa un correo válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: submit,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Iniciar sesión'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Modo de demostración: los datos se mantienen localmente mientras se conecta Firebase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [HomeScreen(), ExploreScreen(), FavoritesScreen(), RoutesScreen(), ProfileScreen()];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'Rutas'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EcoRutaScope.of(context);
    final featured = state.destinations.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoRuta'),
        actions: [
          IconButton(
            tooltip: 'Información',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'EcoRuta',
              applicationVersion: 'MVP 0.1',
              children: const [Text('Turismo sostenible y rutas para descubrir Nicaragua.')],
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Hola, ${state.userName} 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text('¿Qué rincón de Nicaragua quieres descubrir hoy?', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66A34A)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Viaja mejor, conoce más', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Organiza una ruta con varios destinos y guarda tus lugares favoritos.', style: TextStyle(color: Colors.white70, height: 1.4)),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.eco, color: Colors.white, size: 56),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Categorías'),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CategoryChip(label: 'Naturaleza', icon: Icons.park_outlined),
              _CategoryChip(label: 'Playa', icon: Icons.beach_access_outlined),
              _CategoryChip(label: 'Cultura', icon: Icons.museum_outlined),
              _CategoryChip(label: 'Aventura', icon: Icons.hiking_outlined),
              _CategoryChip(label: 'Historia', icon: Icons.history_edu_outlined),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Destinos destacados'),
          const SizedBox(height: 12),
          ...featured.map((destination) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DestinationCard(destination: destination),
              )),
        ],
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
  String query = '';
  String category = 'Todas';

  @override
  Widget build(BuildContext context) {
    final state = EcoRutaScope.of(context);
    const categories = ['Todas', 'Naturaleza', 'Playa', 'Cultura', 'Aventura', 'Historia'];
    final visible = state.destinations.where((destination) {
      final matchesQuery = destination.name.toLowerCase().contains(query.toLowerCase()) ||
          destination.department.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'Todas' || destination.category == category;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar destinos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Buscar destino o departamento',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final item = categories[i];
                return ChoiceChip(
                  label: Text(item),
                  selected: category == item,
                  onSelected: (_) => setState(() => category = item),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? const _EmptyState(icon: Icons.search_off, title: 'Sin resultados', message: 'Prueba con otro término o categoría.')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => DestinationCard(destination: visible[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final state = EcoRutaScope.of(context);
    final favorite = state.favoriteIds.contains(destination.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.name),
        actions: [
          IconButton(
            tooltip: favorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: () => state.toggleFavorite(destination.id),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(colors: [Color(0xFFDAEED1), Color(0xFFA9D19A)]),
            ),
            child: Icon(destination.icon, size: 92, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(destination.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              ),
              Chip(label: Text(destination.category)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 6),
              Text(destination.department),
            ],
          ),
          const SizedBox(height: 20),
          Text('Acerca del lugar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(destination.description, style: const TextStyle(height: 1.6)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    state.toggleFavorite(destination.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(favorite ? 'Eliminado de favoritos' : 'Guardado en favoritos')),
                    );
                  },
                  icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                  label: Text(favorite ? 'Guardado' : 'Guardar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ubicación del destino'),
                      content: Text('El mapa interactivo para ${destination.name} se conectará al servicio de mapas en la integración final.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                    ),
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver mapa'),
                ),
              ),
            ],
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
    final state = EcoRutaScope.of(context);
    final favorites = state.destinations.where((d) => state.favoriteIds.contains(d.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: favorites.isEmpty
          ? const _EmptyState(icon: Icons.favorite_border, title: 'Aún no tienes favoritos', message: 'Guarda destinos desde Explorar para encontrarlos aquí.')
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => DestinationCard(destination: favorites[i]),
            ),
    );
  }
}

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  Future<void> createRoute(BuildContext context) async {
    final state = EcoRutaScope.of(context);
    final nameController = TextEditingController();
    final selected = <String>{};

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear nueva ruta'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre de la ruta')),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Selecciona destinos', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...state.destinations.map(
                    (destination) => CheckboxListTile(
                      value: selected.contains(destination.id),
                      contentPadding: EdgeInsets.zero,
                      title: Text(destination.name),
                      subtitle: Text(destination.department),
                      onChanged: (value) => setDialogState(() {
                        if (value == true) {
                          selected.add(destination.id);
                        } else {
                          selected.remove(destination.id);
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty || selected.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un nombre y selecciona al menos un destino.')),
                  );
                  return;
                }
                state.addRoute(name, selected.toList());
                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar ruta'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = EcoRutaScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis rutas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => createRoute(context),
        icon: const Icon(Icons.add_road),
        label: const Text('Crear ruta'),
      ),
      body: state.routes.isEmpty
          ? const _EmptyState(icon: Icons.route_outlined, title: 'Crea tu primera ruta', message: 'Combina varios destinos de Nicaragua en un mismo recorrido.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: state.routes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final route = state.routes[i];
                final names = state.destinations
                    .where((d) => route.destinationIds.contains(d.id))
                    .map((d) => d.name)
                    .join(' • ');
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(child: Icon(Icons.route)),
                    title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(names)),
                  ),
                );
              },
            ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EcoRutaScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CircleAvatar(radius: 46, child: Icon(Icons.person, size: 46))),
          const SizedBox(height: 14),
          Center(
            child: Text(state.userName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Center(child: Text('Rol: Usuario', style: TextStyle(color: Colors.black54))),
          const SizedBox(height: 28),
          const Card(
            child: ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Cuenta protegida'),
              subtitle: Text('Autenticación y permisos por rol se conectarán con Firebase.'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.eco_outlined),
              title: Text('EcoRuta'),
              subtitle: Text('Aplicación de turismo sostenible enfocada en Nicaragua.'),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: state.logout, icon: const Icon(Icons.logout), label: const Text('Cerrar sesión')),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final state = EcoRutaScope.of(context);
    final favorite = state.favoriteIds.contains(destination.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: destination)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: const Color(0xFFE2F0DD), borderRadius: BorderRadius.circular(18)),
                child: Icon(destination.icon, color: const Color(0xFF2E7D32), size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${destination.department} • ${destination.category}', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              IconButton(
                tooltip: favorite ? 'Quitar favorito' : 'Agregar favorito',
                onPressed: () => state.toggleFavorite(destination.id),
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double size;
  const _BrandMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(size * .3),
        ),
        child: Icon(Icons.eco, color: Colors.white, size: size * .58),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CategoryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800));
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black38),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
