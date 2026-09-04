import 'package:ecoruta/app.dart';
import 'package:ecoruta/app_controller.dart';
import 'package:ecoruta/models/destination.dart';
import 'package:flutter/material.dart';
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

  testWidgets('EcoRuta navega por cinco secciones funcionales', (tester) async {
    final controller = AppController();
    await controller.initialize();

    await tester.pumpWidget(EcoRutaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Descubre Nicaragua\ncon EcoRuta'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hola,'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();
    expect(find.text('Explorar destinos'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Mis favoritos'), findsOneWidget);

    await tester.tap(find.text('Rutas'));
    await tester.pumpAndSettle();
    expect(find.text('Mis rutas'), findsOneWidget);
    expect(find.text('Nueva ruta'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsWidgets);
    expect(find.textContaining('Rol:'), findsOneWidget);
  });

  testWidgets('EcoRuta permite crear una ruta desde la interfaz', (tester) async {
    final controller = AppController();
    await controller.initialize();

    await tester.pumpWidget(EcoRutaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rutas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva ruta'));
    await tester.pumpAndSettle();

    expect(find.text('Crear ruta'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre de la ruta'),
      'Ruta de prueba',
    );

    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsAtLeastNWidgets(2));
    await tester.tap(checkboxes.at(0));
    await tester.pump();
    await tester.tap(checkboxes.at(1));
    await tester.pump();

    await tester.tap(find.text('Guardar ruta'));
    await tester.pumpAndSettle();

    expect(find.text('Mis rutas'), findsOneWidget);
    expect(find.text('Ruta de prueba'), findsOneWidget);
  });
}
