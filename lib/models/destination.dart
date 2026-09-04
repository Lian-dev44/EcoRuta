class Destination {
  final String id;
  final String name;
  final String description;
  final String department;
  final String municipality;
  final String category;
  final double latitude;
  final double longitude;
  final bool active;

  const Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.department,
    required this.municipality,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.active = true,
  });

  factory Destination.fromMap(String id, Map<String, dynamic> data) {
    double number(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return Destination(
      id: id,
      name: (data['nombre'] as String?) ?? 'Destino',
      description: (data['descripcion'] as String?) ?? '',
      department: (data['departamento'] as String?) ?? '',
      municipality: (data['municipio'] as String?) ?? '',
      category: (data['categoria'] as String?) ??
          (data['categoriaId'] as String?) ??
          'Naturaleza',
      latitude: number(data['latitud']),
      longitude: number(data['longitud']),
      active: (data['activo'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idDestino': id,
      'nombre': name,
      'descripcion': description,
      'departamento': department,
      'municipio': municipality,
      'categoria': category,
      'categoriaId': category.toLowerCase(),
      'latitud': latitude,
      'longitud': longitude,
      'activo': active,
    };
  }
}
