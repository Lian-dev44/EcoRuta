import '../models/app_user.dart';
import '../models/destination.dart';
import '../models/tour_route.dart';

abstract class EcoRutaRepository {
  bool get isRemote;
  String get backendLabel;

  Future<AppUser?> restoreSession();

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<List<Destination>> getDestinations();

  Future<Set<String>> getFavoriteIds(String uid);

  Future<void> setFavorite({
    required String uid,
    required String destinationId,
    required bool favorite,
  });

  Future<List<TourRoute>> getRoutes(String uid);

  Future<void> createRoute({
    required String uid,
    required String name,
    required List<String> destinationIds,
  });

  Future<void> seedDestinations();
}
