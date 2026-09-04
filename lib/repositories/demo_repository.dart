import '../data/sample_data.dart';
import '../models/app_user.dart';
import '../models/destination.dart';
import '../models/tour_route.dart';
import 'ecoruta_repository.dart';

class DemoRepository implements EcoRutaRepository {
  AppUser? _user;
  final Set<String> _favorites = {'volcan_masaya'};
  final List<TourRoute> _routes = [];

  @override
  bool get isRemote => false;

  @override
  String get backendLabel => 'Modo demostración local';

  @override
  Future<AppUser?> restoreSession() async => _user;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!email.contains('@')) {
      throw Exception('Ingresa un correo válido.');
    }
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres.');
    }

    final rawName = email.split('@').first.trim();
    _user = AppUser(
      uid: 'demo-user',
      name: rawName.isEmpty ? 'Explorador' : _capitalize(rawName),
      email: email,
      role: 'usuario',
    );
    return _user!;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _user = AppUser(
      uid: 'demo-user',
      name: name.trim().isEmpty ? 'Explorador' : name.trim(),
      email: email,
      role: 'usuario',
    );
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<List<Destination>> getDestinations() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<Destination>.from(sampleDestinations);
  }

  @override
  Future<Set<String>> getFavoriteIds(String uid) async =>
      Set<String>.from(_favorites);

  @override
  Future<void> setFavorite({
    required String uid,
    required String destinationId,
    required bool favorite,
  }) async {
    if (favorite) {
      _favorites.add(destinationId);
    } else {
      _favorites.remove(destinationId);
    }
  }

  @override
  Future<List<TourRoute>> getRoutes(String uid) async =>
      List<TourRoute>.from(_routes);

  @override
  Future<void> createRoute({
    required String uid,
    required String name,
    required List<String> destinationIds,
  }) async {
    _routes.insert(
      0,
      TourRoute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        destinationIds: List<String>.from(destinationIds),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> seedDestinations() async {}

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
