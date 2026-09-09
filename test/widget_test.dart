import 'package:flutter_test/flutter_test.dart';
import 'package:gamerpg2dpixelqt/main.dart';

void main() {
  testWidgets('GameApp builds and initializes properly', (WidgetTester tester) async {
    await tester.pumpWidget(const GameApp());
    expect(find.byType(GameApp), findsOneWidget);
  });
}
