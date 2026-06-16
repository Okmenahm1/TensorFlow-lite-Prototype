import 'package:flutter_test/flutter_test.dart';
import 'package:androidproject/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(cameras: []));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
