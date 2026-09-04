class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: (data['nombre'] as String?)?.trim().isNotEmpty == true
          ? (data['nombre'] as String).trim()
          : 'Explorador',
      email: (data['correo'] as String?) ?? '',
      role: (data['rol'] as String?) ?? 'usuario',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': name,
      'correo': email,
      'rol': role,
      'activo': true,
    };
  }
}
