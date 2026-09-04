import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../app_scope.dart';
import '../models/destination.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';
import '../widgets/ecoruta_widgets.dart';

class MapScreen extends StatefulWidget {
  final List<Destination> initialStops;
  final String? routeName;

  const MapScreen({
    super.key,
    this.initialStops = const [],
    this.routeName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _nicaraguaCenter = LatLng(12.8654, -85.2072);
  static const _arrivalRadiusMeters = 120.0;
  static const _rerouteDistanceMeters = 60.0;
  static const _rerouteInterval = Duration(seconds: 12);

  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();

  StreamSubscription<Position>? _positionSubscription;
  Position? _position;
  Destination? _selectedDestination;
  RoutePlan? _routePlan;
  List<Destination> _activeStops = [];
  Position? _lastReroutePosition;
  DateTime? _lastRerouteAt;
  String? _activeRouteName;
  String? _locationMessage;
  bool _locating = false;
  bool _routing = false;
  bool _navigationActive = false;
  bool _followUser = true;
  bool _hasCenteredOnUser = false;

  LatLng? get _userPoint => _position == null
      ? null
      : LatLng(_position!.latitude, _position!.longitude);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    await _locateUser();
    if (!mounted || widget.initialStops.isEmpty) return;
    await _startNavigation(
      widget.initialStops,
      routeName: widget.routeName ?? 'Ruta personalizada',
      focusWholeRoute: true,
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _routingService.dispose();
    super.dispose();
  }

  Future<void> _locateUser({bool forceCenter = false}) async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _locationMessage = null;
    });

    try {
      final position = await _locationService.requestCurrentPosition();
      if (!mounted) return;
      setState(() => _position = position);
      _centerOnUser(force: forceCenter || !_hasCenteredOnUser);
      _listenToPosition();
    } on LocationAccessException catch (error) {
      if (!mounted) return;
      setState(() => _locationMessage = error.message);
      _showLocationHelp(error);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationMessage =
            'No se pudo obtener tu ubicación. Revisa GPS, permisos y conexión.';
      });
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _listenToPosition() {
    if (_positionSubscription != null) return;
    _positionSubscription = _locationService.positionStream().listen(
      (position) {
        if (!mounted) return;
        setState(() => _position = position);

        if (_navigationActive && _followUser) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.3,
          );
        }

        if (_navigationActive) {
          unawaited(_handleNavigationPosition(position));
        }
      },
      onError: (_) {},
    );
  }

  Future<void> _handleNavigationPosition(Position position) async {
    if (!_navigationActive || _activeStops.isEmpty || _routing) return;

    final nextStop = _activeStops.first;
    final distanceToStop = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      nextStop.latitude,
      nextStop.longitude,
    );

    if (distanceToStop <= _arrivalRadiusMeters) {
      final reached = nextStop;
      setState(() => _activeStops = _activeStops.skip(1).toList());

      if (_activeStops.isEmpty) {
        setState(() {
          _navigationActive = false;
          _activeRouteName = null;
        });
        _showMessage('Llegaste a ${reached.name}. Ruta completada.');
        return;
      }

      _showMessage(
        'Llegaste a ${reached.name}. Siguiente: ${_activeStops.first.name}.',
      );
      await _recalculateActiveRoute(force: true);
      return;
    }

    final lastPosition = _lastReroutePosition;
    final lastTime = _lastRerouteAt;
    if (lastPosition == null || lastTime == null) return;

    final moved = Geolocator.distanceBetween(
      lastPosition.latitude,
      lastPosition.longitude,
      position.latitude,
      position.longitude,
    );
    final enoughTime = DateTime.now().difference(lastTime) >= _rerouteInterval;

    if (moved >= _rerouteDistanceMeters && enoughTime) {
      await _recalculateActiveRoute();
    }
  }

  Future<void> _recalculateActiveRoute({bool force = false}) async {
    final origin = _userPoint;
    if (!_navigationActive || origin == null || _activeStops.isEmpty || _routing) {
      return;
    }

    if (!force && _lastRerouteAt != null) {
      final elapsed = DateTime.now().difference(_lastRerouteAt!);
      if (elapsed < _rerouteInterval) return;
    }

    setState(() => _routing = true);
    try {
      final plan = await _routingService.routeThroughStops(
        origin: origin,
        stops: _activeStops,
      );
      if (!mounted) return;
      setState(() {
        _routePlan = plan;
        _lastReroutePosition = _position;
        _lastRerouteAt = DateTime.now();
      });
    } on RoutingException catch (error) {
      if (mounted) _showMessage('No se pudo recalcular: ${error.message}');
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  void _centerOnUser({bool force = false}) {
    final point = _userPoint;
    if (point == null || (!force && _hasCenteredOnUser)) return;
    _mapController.move(point, _navigationActive ? 15.3 : 13.2);
    _hasCenteredOnUser = true;
  }

  Future<void> _showLocationHelp(LocationAccessException error) async {
    if (!mounted) return;
    final action = error.openAppSettings
        ? 'Abrir ajustes de la app'
        : error.openLocationSettings
            ? 'Activar ubicación'
            : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        action: action == null
            ? null
            : SnackBarAction(
                label: action,
                onPressed: () {
                  if (error.openAppSettings) {
                    _locationService.openApplicationSettings();
                  } else if (error.openLocationSettings) {
                    _locationService.openDeviceLocationSettings();
                  }
                },
              ),
      ),
    );
  }

  Future<void> _chooseDestination() async {
    final controller = EcoRutaScope.of(context);
    final selected = await showSearch<Destination?>(
      context: context,
      delegate: _DestinationSearchDelegate(controller.destinations),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedDestination = selected);
    _mapController.move(LatLng(selected.latitude, selected.longitude), 12.4);
  }

  Future<LatLng?> _ensureUserLocation() async {
    if (_userPoint != null) return _userPoint;
    await _locateUser(forceCenter: true);
    return _userPoint;
  }

  Future<void> _routeToSelected() async {
    final destination = _selectedDestination;
    if (destination == null) return;
    await _startNavigation(
      [destination],
      routeName: 'Hacia ${destination.name}',
      focusWholeRoute: true,
    );
  }

  Future<void> _startNavigation(
    List<Destination> stops, {
    required String routeName,
    bool focusWholeRoute = false,
  }) async {
    if (_routing || stops.isEmpty) return;
    final origin = await _ensureUserLocation();
    if (origin == null || !mounted) return;

    setState(() => _routing = true);
    try {
      final plan = await _routingService.routeThroughStops(
        origin: origin,
        stops: stops,
      );
      if (!mounted) return;
      setState(() {
        _routePlan = plan;
        _activeStops = List<Destination>.from(stops);
        _activeRouteName = routeName;
        _navigationActive = true;
        _followUser = true;
        _lastReroutePosition = _position;
        _lastRerouteAt = DateTime.now();
      });
      if (focusWholeRoute) {
        _focusRoute(plan.points);
      } else {
        _centerOnUser(force: true);
      }
    } on RoutingException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  Future<void> _suggestRoute() async {
    if (_routing) return;
    final controller = EcoRutaScope.of(context);
    final origin = await _ensureUserLocation();
    if (origin == null || !mounted) return;

    setState(() {
      _routing = true;
      _selectedDestination = null;
    });

    try {
      final plan = await _routingService.suggestRoute(
        origin: origin,
        destinations: controller.destinations,
        stopCount: 4,
      );
      if (!mounted) return;
      setState(() {
        _routePlan = plan;
        _activeStops = List<Destination>.from(plan.stops);
        _activeRouteName = 'Ruta sugerida';
        _navigationActive = true;
        _followUser = true;
        _lastReroutePosition = _position;
        _lastRerouteAt = DateTime.now();
      });
      _focusRoute(plan.points);
    } on RoutingException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  Future<void> _saveCurrentRoute() async {
    final plan = _routePlan;
    if (plan == null || plan.stops.length < 2) return;
    final controller = EcoRutaScope.of(context);
    final now = DateTime.now();
    final name = _activeRouteName == 'Ruta sugerida'
        ? 'Ruta sugerida ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}'
        : (_activeRouteName ?? 'Ruta EcoRuta');

    try {
      await controller.createRoute(
        name,
        plan.stops.map((destination) => destination.id).toList(),
      );
      if (mounted) _showMessage('Ruta guardada en Mis rutas.');
    } catch (_) {
      if (mounted) {
        _showMessage(controller.lastError ?? 'No se pudo guardar la ruta.');
      }
    }
  }

  void _stopNavigation() {
    setState(() {
      _navigationActive = false;
      _activeStops = [];
      _activeRouteName = null;
      _routePlan = null;
      _lastRerouteAt = null;
      _lastReroutePosition = null;
    });
    _showMessage('Navegación detenida.');
  }

  void _toggleFollow() {
    setState(() => _followUser = !_followUser);
    if (_followUser) _centerOnUser(force: true);
  }

  void _focusRoute(List<LatLng> points) {
    if (points.isEmpty) return;
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLon = points.first.longitude;
    var maxLon = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLon = math.min(minLon, point.longitude);
      maxLon = math.max(maxLon, point.longitude);
    }

    final center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
    final span = math.max(maxLat - minLat, maxLon - minLon);
    final zoom = span < 0.04
        ? 13.2
        : span < 0.10
            ? 11.8
            : span < 0.25
                ? 10.2
                : span < 0.55
                    ? 9.0
                    : span < 1.1
                        ? 8.0
                        : 7.0;
    _mapController.move(center, zoom);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = EcoRutaScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final userPoint = _userPoint;
    final plan = _routePlan;

    final markers = <Marker>[
      for (final destination in controller.destinations)
        Marker(
          point: LatLng(destination.latitude, destination.longitude),
          width: 50,
          height: 54,
          child: _DestinationMarker(
            destination: destination,
            selected: _selectedDestination?.id == destination.id ||
                _activeStops.any((stop) => stop.id == destination.id),
            onTap: () => setState(() => _selectedDestination = destination),
          ),
        ),
      if (userPoint != null)
        Marker(
          point: userPoint,
          width: 58,
          height: 58,
          child: _UserLocationMarker(navigationActive: _navigationActive),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_navigationActive ? 'Navegación EcoRuta' : 'Mapa inteligente'),
        actions: [
          if (_navigationActive)
            IconButton(
              tooltip: _followUser ? 'Dejar de seguir' : 'Seguir mi posición',
              onPressed: _toggleFollow,
              icon: Icon(
                _followUser ? Icons.navigation : Icons.navigation_outlined,
              ),
            ),
          IconButton(
            tooltip: 'Centrar en mi ubicación',
            onPressed: _locating ? null : () => _locateUser(forceCenter: true),
            icon: _locating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _nicaraguaCenter,
              initialZoom: 7.2,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecoruta.ecoruta',
              ),
              if (plan != null && plan.points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: plan.points,
                      strokeWidth: 7,
                      color: colorScheme.primary,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
              const RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (!_navigationActive)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: SafeArea(
                bottom: false,
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  child: InkWell(
                    onTap: _chooseDestination,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '¿A dónde quieres ir?',
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedDestination?.name ??
                                      'Busca entre ${controller.destinations.length} destinos',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 12,
            bottom: plan == null ? 190 : 290,
            child: FloatingActionButton.small(
              heroTag: 'locate-map',
              tooltip: 'Mi ubicación',
              onPressed: _locating ? null : () => _locateUser(forceCenter: true),
              child: const Icon(Icons.gps_fixed),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _MapActionCard(
              locationAvailable: userPoint != null,
              locationMessage: _locationMessage,
              selectedDestination: _selectedDestination,
              routePlan: plan,
              routeName: _activeRouteName,
              nextStop: _activeStops.isEmpty ? null : _activeStops.first,
              navigationActive: _navigationActive,
              followUser: _followUser,
              routing: _routing,
              onChooseDestination: _chooseDestination,
              onRouteToSelected: _routeToSelected,
              onSuggestRoute: _suggestRoute,
              onSaveRoute: _saveCurrentRoute,
              onStopNavigation: _stopNavigation,
              onToggleFollow: _toggleFollow,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionCard extends StatelessWidget {
  final bool locationAvailable;
  final String? locationMessage;
  final Destination? selectedDestination;
  final RoutePlan? routePlan;
  final String? routeName;
  final Destination? nextStop;
  final bool navigationActive;
  final bool followUser;
  final bool routing;
  final VoidCallback onChooseDestination;
  final VoidCallback onRouteToSelected;
  final VoidCallback onSuggestRoute;
  final VoidCallback onSaveRoute;
  final VoidCallback onStopNavigation;
  final VoidCallback onToggleFollow;

  const _MapActionCard({
    required this.locationAvailable,
    required this.locationMessage,
    required this.selectedDestination,
    required this.routePlan,
    required this.routeName,
    required this.nextStop,
    required this.navigationActive,
    required this.followUser,
    required this.routing,
    required this.onChooseDestination,
    required this.onRouteToSelected,
    required this.onSuggestRoute,
    required this.onSaveRoute,
    required this.onStopNavigation,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final plan = routePlan;
    return Material(
      elevation: 7,
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: plan == null ? _idle(context) : _route(context, plan),
      ),
    );
  }

  Widget _idle(BuildContext context) {
    final locationText = locationAvailable
        ? 'Ubicación GPS activa y monitoreándose'
        : (locationMessage ?? 'Permite la ubicación para calcular desde donde estás.');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                locationAvailable ? Icons.gps_fixed : Icons.location_off_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explora Nicaragua desde donde estás',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    locationText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: routing
                    ? null
                    : selectedDestination == null
                        ? onChooseDestination
                        : onRouteToSelected,
                icon: const Icon(Icons.navigation_outlined),
                label: Text(
                  selectedDestination == null ? 'Elegir destino' : 'Llévame aquí',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: routing ? null : onSuggestRoute,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Sugerir ruta'),
              ),
            ),
          ],
        ),
        if (routing) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 6),
          const Text(
            'Calculando la mejor ruta disponible…',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ],
    );
  }

  Widget _route(BuildContext context, RoutePlan plan) {
    final title = navigationActive
        ? (routeName ?? 'Navegación activa')
        : (plan.suggested ? 'Ruta sugerida para ti' : 'Ruta calculada');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: navigationActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            if (routing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        if (nextStop != null) ...[
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Siguiente parada: ${nextStop!.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(icon: Icons.route, text: plan.distanceLabel),
            _InfoChip(icon: Icons.schedule, text: plan.durationLabel),
            _InfoChip(
              icon: Icons.place_outlined,
              text: '${plan.stops.length} parada${plan.stops.length == 1 ? '' : 's'}',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          plan.stops.map((stop) => stop.name).join('  →  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, height: 1.35),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: navigationActive ? onToggleFollow : onSaveRoute,
                icon: Icon(
                  navigationActive
                      ? (followUser ? Icons.navigation : Icons.navigation_outlined)
                      : Icons.bookmark_add_outlined,
                ),
                label: Text(
                  navigationActive
                      ? (followUser ? 'Siguiendo' : 'Seguirme')
                      : 'Guardar ruta',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: navigationActive ? onStopNavigation : onSuggestRoute,
                icon: Icon(
                  navigationActive ? Icons.stop_circle_outlined : Icons.auto_awesome,
                ),
                label: Text(navigationActive ? 'Detener' : 'Otra ruta'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  final Destination destination;
  final bool selected;
  final VoidCallback onTap;

  const _DestinationMarker({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 42 : 36,
            height: selected ? 42 : 36,
            decoration: BoxDecoration(
              color: selected ? primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              iconForCategory(destination.category),
              size: selected ? 23 : 20,
              color: selected ? Colors.white : primary,
            ),
          ),
          Container(width: 3, height: 7, color: primary),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  final bool navigationActive;

  const _UserLocationMarker({required this.navigationActive});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: navigationActive ? 54 : 46,
          height: navigationActive ? 54 : 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: navigationActive ? 0.20 : 0.14),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestinationSearchDelegate extends SearchDelegate<Destination?> {
  final List<Destination> destinations;

  _DestinationSearchDelegate(this.destinations);

  @override
  String? get searchFieldLabel => 'Destino, municipio o departamento';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            onPressed: () => query = '',
            icon: const Icon(Icons.clear),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final matches = destinations.where((destination) {
      if (normalized.isEmpty) return true;
      return destination.name.toLowerCase().contains(normalized) ||
          destination.department.toLowerCase().contains(normalized) ||
          destination.municipality.toLowerCase().contains(normalized) ||
          destination.category.toLowerCase().contains(normalized);
    }).toList();

    if (matches.isEmpty) {
      return const Center(child: Text('No encontramos destinos con esa búsqueda.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final destination = matches[index];
        return ListTile(
          leading: CircleAvatar(child: Icon(iconForCategory(destination.category))),
          title: Text(destination.name),
          subtitle: Text('${destination.municipality} · ${destination.department}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => close(context, destination),
        );
      },
    );
  }
}
