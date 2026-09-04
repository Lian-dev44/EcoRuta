import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/destination.dart';

class RoutePlan {
  final List<LatLng> points;
  final List<Destination> stops;
  final double distanceMeters;
  final double durationSeconds;
  final bool suggested;

  const RoutePlan({
    required this.points,
    required this.stops,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.suggested,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get durationLabel {
    final totalMinutes = (durationSeconds / 60).round();
    if (totalMinutes < 60) return '$totalMinutes min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return minutes == 0 ? '$hours h' : '$hours h $minutes min';
  }
}

class RoutingException implements Exception {
  final String message;
  const RoutingException(this.message);

  @override
  String toString() => message;
}

class RoutingService {
  static const _host = 'router.project-osrm.org';
  static const _headers = <String, String>{
    'User-Agent': 'EcoRuta/0.4 (Hackathon Nicaragua 2026)',
    'Accept': 'application/json',
  };

  final http.Client _client;
  final Distance _distance = const Distance();

  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  Future<RoutePlan> routeTo({
    required LatLng origin,
    required Destination destination,
  }) {
    return routeThroughStops(
      origin: origin,
      stops: [destination],
    );
  }

  Future<RoutePlan> routeThroughStops({
    required LatLng origin,
    required List<Destination> stops,
  }) async {
    if (stops.isEmpty) {
      throw const RoutingException('La ruta no contiene destinos disponibles.');
    }

    final coordinates = <String>[
      _coordinate(origin),
      ...stops.map(
        (destination) =>
            '${destination.longitude.toStringAsFixed(6)},${destination.latitude.toStringAsFixed(6)}',
      ),
    ].join(';');

    final uri = Uri.https(
      _host,
      '/route/v1/driving/$coordinates',
      const {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true',
      },
    );

    final data = await _get(uri);
    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const RoutingException(
        'No se encontró una ruta vehicular para los destinos seleccionados.',
      );
    }

    final route = Map<String, dynamic>.from(routes.first as Map);
    return RoutePlan(
      points: _geometry(route),
      stops: List<Destination>.from(stops),
      distanceMeters: _number(route['distance']),
      durationSeconds: _number(route['duration']),
      suggested: false,
    );
  }

  Future<RoutePlan> suggestRoute({
    required LatLng origin,
    required List<Destination> destinations,
    int stopCount = 4,
  }) async {
    final selected = selectSuggestedDestinations(
      origin: origin,
      destinations: destinations,
      stopCount: stopCount,
    );

    if (selected.length < 2) {
      throw const RoutingException(
        'No hay suficientes destinos disponibles para sugerir una ruta.',
      );
    }

    final coordinates = <String>[
      _coordinate(origin),
      ...selected.map(
        (destination) =>
            '${destination.longitude.toStringAsFixed(6)},${destination.latitude.toStringAsFixed(6)}',
      ),
    ].join(';');

    final uri = Uri.https(
      _host,
      '/trip/v1/driving/$coordinates',
      const {
        'source': 'first',
        'roundtrip': 'false',
        'destination': 'last',
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true',
      },
    );

    final data = await _get(uri);
    final trips = data['trips'] as List<dynamic>?;
    if (trips == null || trips.isEmpty) {
      throw const RoutingException(
        'No se pudo construir una ruta turística con esos destinos.',
      );
    }

    final trip = Map<String, dynamic>.from(trips.first as Map);
    final orderedStops = _orderedStops(data['waypoints'], selected);

    return RoutePlan(
      points: _geometry(trip),
      stops: orderedStops,
      distanceMeters: _number(trip['distance']),
      durationSeconds: _number(trip['duration']),
      suggested: true,
    );
  }

  List<Destination> selectSuggestedDestinations({
    required LatLng origin,
    required List<Destination> destinations,
    int stopCount = 4,
  }) {
    if (destinations.isEmpty || stopCount <= 0) return const [];

    final ranked = List<Destination>.from(destinations)
      ..sort((a, b) {
        final distanceA = _distance(
          origin,
          LatLng(a.latitude, a.longitude),
        );
        final distanceB = _distance(
          origin,
          LatLng(b.latitude, b.longitude),
        );
        return distanceA.compareTo(distanceB);
      });

    final pool = ranked.take(ranked.length > 14 ? 14 : ranked.length).toList();
    final result = <Destination>[];
    final usedCategories = <String>{};

    for (final destination in pool) {
      if (result.length >= stopCount) break;
      if (usedCategories.add(destination.category)) {
        result.add(destination);
      }
    }

    for (final destination in pool) {
      if (result.length >= stopCount) break;
      if (!result.any((item) => item.id == destination.id)) {
        result.add(destination);
      }
    }

    return result;
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    http.Response response;
    try {
      response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      throw const RoutingException(
        'No se pudo contactar el servicio de rutas. Revisa tu conexión.',
      );
    }

    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw const RoutingException('El servicio de rutas respondió con un error.');
    }

    if (response.statusCode != 200 || data['code'] != 'Ok') {
      final message = data['message']?.toString();
      throw RoutingException(
        message == null || message.isEmpty
            ? 'No fue posible generar la ruta solicitada.'
            : 'No fue posible generar la ruta: $message',
      );
    }

    return data;
  }

  List<LatLng> _geometry(Map<String, dynamic> route) {
    final geometry = route['geometry'];
    if (geometry is! Map) return const [];
    final coordinates = geometry['coordinates'];
    if (coordinates is! List) return const [];

    return coordinates.map<LatLng>((raw) {
      final pair = raw as List<dynamic>;
      return LatLng(
        (pair[1] as num).toDouble(),
        (pair[0] as num).toDouble(),
      );
    }).toList();
  }

  List<Destination> _orderedStops(
    dynamic rawWaypoints,
    List<Destination> selected,
  ) {
    if (rawWaypoints is! List || rawWaypoints.length != selected.length + 1) {
      return selected;
    }

    final ordered = <({Destination destination, int index})>[];
    for (var i = 0; i < selected.length; i++) {
      final waypoint = rawWaypoints[i + 1];
      if (waypoint is Map && waypoint['waypoint_index'] is num) {
        ordered.add((
          destination: selected[i],
          index: (waypoint['waypoint_index'] as num).toInt(),
        ));
      }
    }

    if (ordered.length != selected.length) return selected;
    ordered.sort((a, b) => a.index.compareTo(b.index));
    return ordered.map((item) => item.destination).toList();
  }

  String _coordinate(LatLng point) =>
      '${point.longitude.toStringAsFixed(6)},${point.latitude.toStringAsFixed(6)}';

  double _number(dynamic value) => value is num ? value.toDouble() : 0;

  void dispose() => _client.close();
}
