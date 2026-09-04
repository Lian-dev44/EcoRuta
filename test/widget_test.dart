import 'package:ecoruta/models/destination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Destination conserva los datos principales', () {
    const destination = Destination(
      id: 'prueba',
      name: 'Destino de prueba',
      description: 'Descripción',
      department: 'Managua',
      municipality: 'Managua',
      category: 'Cultura',
      latitude: 12.0,
      longitude: -86.0,
    );

    final map = destination.toMap();

    expect(map['nombre'], 'Destino de prueba');
    expect(map['departamento'], 'Managua');
    expect(map['activo'], isTrue);
  });
}
