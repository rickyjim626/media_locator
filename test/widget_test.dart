import 'package:flutter_test/flutter_test.dart';
import 'package:media_locator/main.dart';
import 'package:media_locator/src/services/database_service.dart';

void main() {
  testWidgets('MyApp has a title', (WidgetTester tester) async {
    final databaseService = DatabaseService();
    await databaseService.initialize();

    await tester.pumpWidget(MyApp(databaseService: databaseService));

    final titleFinder = find.text('媒体定位器');
    expect(titleFinder, findsOneWidget);
  });
}