import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto/main.dart';

void main() {
  testWidgets('muestra la pantalla de inicio de sesion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('¿Nuevo trabajador? Registrar aquí'), findsOneWidget);
  });
}
