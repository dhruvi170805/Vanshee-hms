import 'package:flutter_test/flutter_test.dart';
import 'package:hms_frontend/main.dart';

void main() {
  testWidgets('HMS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HmsApp());
    expect(find.byType(HmsApp), findsOneWidget);
  });
}
