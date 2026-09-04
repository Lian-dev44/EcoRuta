import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/sample_data.dart';
import '../models/app_user.dart';
import '../models/destination.dart';
import '../models/tour_route.dart';
import 'ecoruta_repository.dart';

class FirebaseRepository implements EcoRutaRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  @override
  bool get isRemote => true;

  @override
  String get backendLabel => 'Firebase conectado';

  @override
  Future<AppUser?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadOrCreateProfile(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) throw Exception('No se pudo iniciar sesión.');
      return await _loadOrCreateProfile(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authMessage(e));
    }
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) throw Exception('No se pudo crear la cuenta.');

      final profile = AppUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: 'usuario',
      );

      await _db.collection('usuarios').doc(user.uid).set({
        ...profile.toMap(),
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      return profile;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authMessage(e));
    }
  }

  Future<AppUser> _loadOrCreateProfile(User user) async {
    final ref = _db.collection('usuarios').doc(user.uid);
    final snapshot = await ref.get();

    if (snapshot.exists && snapshot.data() != null) {
      return AppUser.fromMap(user.uid, snapshot.data()!);
    }

    final fallbackName = (user.email ?? 'explorador').split('@').first;
    final profile = AppUser(
      uid: user.uid,
      name: fallbackName.isEmpty ? 'Explorador' : fallbackName,
      email: user.email ?? '',
      role: 'usuario',
    );

    await ref.set({
      ...profile.toMap(),
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    return profile;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<List<Destination>> getDestinations() async {
    final snapshot = await _db.collection('destinos').get();

    if (snapshot.docs.isEmpty) {
      final currentUser = _auth.currentUser;

      // Si el usuario autenticado es administrador, dejamos la lista vacía
      // para que Perfil muestre el botón de carga inicial de destinos.
      if (currentUser != null) {
        final profile = await _db.collection('usuarios').doc(currentUser.uid).get();
        final role = profile.data()?['rol'] as String?;
        if (role == 'admin') {
          return <Destination>[];
        }
      }

      // Para usuarios normales, la app sigue siendo navegable mientras
      // Firestore todavía no tiene cargado el catálogo inicial.
      return List<Destination>.from(sampleDestinations);
    }

    final destinations = snapshot.docs
        .map((doc) => Destination.fromMap(doc.id, doc.data()))
        .where((destination) => destination.active)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return destinations;
  }

  @override
  Future<Set<String>> getFavoriteIds(String uid) async {
    final snapshot = await _db
        .collection('favoritos')
        .where('usuarioId', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['destinoId'] as String?)
        .whereType<String>()
        .toSet();
  }

  @override
  Future<void> setFavorite({
    required String uid,
    required String destinationId,
    required bool favorite,
  }) async {
    final id = '${uid}_$destinationId';
    final ref = _db.collection('favoritos').doc(id);

    if (favorite) {
      await ref.set({
        'idFavorito': id,
        'usuarioId': uid,
        'destinoId': destinationId,
        'fechaAgregado': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  @override
  Future<List<TourRoute>> getRoutes(String uid) async {
    final snapshot =
        await _db.collection('rutas').where('usuarioId', isEqualTo: uid).get();

    final routes = snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['fechaCreacion'];
      return TourRoute(
        id: doc.id,
        name: (data['nombre'] as String?) ?? 'Ruta',
        destinationIds:
            List<String>.from((data['destinoIds'] as List?) ?? const []),
        createdAt:
            timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return routes;
  }

  @override
  Future<void> createRoute({
    required String uid,
    required String name,
    required List<String> destinationIds,
  }) async {
    await _db.collection('rutas').add({
      'usuarioId': uid,
      'nombre': name.trim(),
      'descripcion': '',
      'destinoIds': destinationIds,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'activa': true,
    });
  }

  @override
  Future<void> seedDestinations() async {
    final current = await _db.collection('destinos').limit(1).get();
    if (current.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final destination in sampleDestinations) {
      batch.set(
        _db.collection('destinos').doc(destination.id),
        {
          ...destination.toMap(),
          'fechaCreacion': FieldValue.serverTimestamp(),
        },
      );
    }
    await batch.commit();
  }

  static String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'network-request-failed':
        return 'No se pudo conectar a Internet.';
      default:
        return e.message ?? 'Ocurrió un error de autenticación.';
    }
  }
}
