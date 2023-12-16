import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:exemplofloor1/main.dart';

// Crie um mock para o AppDatabase
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Crie um mock para o AppDatabase
    final mockDatabase = MockAppDatabase();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(database: mockDatabase));

    // Seu teste continua aqui
  });
}
