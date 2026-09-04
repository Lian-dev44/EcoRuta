import 'package:geolocator/geolocator.dart';

class LocationAccessException implements Exception {
  final String message;
  final bool openAppSettings;
  final bool openLocationSettings;

  const LocationAccessException(
    this.message, {
    this.openAppSettings = false,
    this.openLocationSettings = false,
  });

  @override
  String toString() => message;
}

class LocationService {
  static const LocationSettings _currentSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
    timeLimit: Duration(seconds: 15),
  );

  static const LocationSettings _streamSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
  );

  Future<Position> requestCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationAccessException(
        'Activa la ubicación del teléfono para usar el mapa y generar rutas desde tu posición.',
        openLocationSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationAccessException(
        'EcoRuta necesita permiso de ubicación para mostrar tu posición y calcular rutas.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationAccessException(
        'El permiso de ubicación está bloqueado. Habilítalo desde los ajustes de la aplicación.',
        openAppSettings: true,
      );
    }

    return Geolocator.getCurrentPosition(locationSettings: _currentSettings);
  }

  Stream<Position> positionStream() =>
      Geolocator.getPositionStream(locationSettings: _streamSettings);

  Future<void> openApplicationSettings() => Geolocator.openAppSettings();

  Future<void> openDeviceLocationSettings() => Geolocator.openLocationSettings();
}
