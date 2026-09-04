import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'models/app_user.dart';
import 'models/destination.dart';
import 'models/tour_route.dart';
import 'repositories/demo_repository.dart';
import 'repositories/ecoruta_repository.dart';
import 'repositories/firebase_repository.dart';
import 'services/firebase_config.dart';

class AppController extends ChangeNotifier {
  final EcoRutaRepository? repositoryOverride;

  AppController({this.repositoryOverride});

  late EcoRutaRepository repository;

  AppUser? user;
  List<Destination> destinations = [];
  Set<String> favoriteIds = {};
  List<TourRoute> routes = [];

  bool initializing = true;
  bool busy = false;
  String? startupWarning;
  String? lastError;

  bool get isLoggedIn => user != null;
  bool get isRemoteBackend => repository.isRemote;
  String get backendLabel => repository.backendLabel;

  Future<void> initialize() async {
    try {
      if (repositoryOverride != null) {
        repository = repositoryOverride!;
      } else if (EcoRutaFirebaseConfig.isConfigured) {
        await Firebase.initializeApp(options: EcoRutaFirebaseConfig.options);
        repository = FirebaseRepository();
      } else {
        repository = DemoRepository();
        startupWarning =
            'Firebase aún no está configurado. EcoRuta está usando el modo demostración local.';
      }
    } catch (error) {
      repository = DemoRepository();
      startupWarning =
          'No se pudo iniciar Firebase. Se activó el modo demostración local: $error';
    }

    try {
      user = await repository.restoreSession();
      if (user != null) {
        await _loadUserData();
      } else {
        destinations = await repository.getDestinations();
      }
    } catch (error) {
      startupWarning = 'No se pudieron cargar los datos iniciales: $error';
    } finally {
      initializing = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _runBusy(() async {
      user = await repository.signIn(email: email, password: password);
      await _loadUserData();
    });
  }

  Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    await _runBusy(() async {
      user = await repository.register(
        name: name,
        email: email,
        password: password,
      );
      await _loadUserData();
    });
  }

  Future<void> signOut() async {
    await _runBusy(() async {
      await repository.signOut();
      user = null;
      favoriteIds = {};
      routes = [];
      destinations = await repository.getDestinations();
    });
  }

  Future<void> refresh() async {
    if (user == null) return;
    await _runBusy(_loadUserData);
  }

  Future<void> toggleFavorite(String destinationId) async {
    final current = user;
    if (current == null) return;

    final shouldFavorite = !favoriteIds.contains(destinationId);
    final previous = Set<String>.from(favoriteIds);

    if (shouldFavorite) {
      favoriteIds.add(destinationId);
    } else {
      favoriteIds.remove(destinationId);
    }
    notifyListeners();

    try {
      await repository.setFavorite(
        uid: current.uid,
        destinationId: destinationId,
        favorite: shouldFavorite,
      );
    } catch (error) {
      favoriteIds = previous;
      lastError = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createRoute(
    String name,
    List<String> destinationIds,
  ) async {
    final current = user;
    if (current == null) return;

    await _runBusy(() async {
      await repository.createRoute(
        uid: current.uid,
        name: name,
        destinationIds: destinationIds,
      );
      routes = await repository.getRoutes(current.uid);
    });
  }

  Future<void> seedRemoteDestinations() async {
    await _runBusy(() async {
      await repository.seedDestinations();
      destinations = await repository.getDestinations();
    });
  }

  Future<void> _loadUserData() async {
    final current = user;
    if (current == null) return;

    final results = await Future.wait([
      repository.getDestinations(),
      repository.getFavoriteIds(current.uid),
      repository.getRoutes(current.uid),
    ]);

    destinations = results[0] as List<Destination>;
    favoriteIds = results[1] as Set<String>;
    routes = results[2] as List<TourRoute>;
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    busy = true;
    lastError = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      lastError = _cleanError(error);
      notifyListeners();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  static String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
