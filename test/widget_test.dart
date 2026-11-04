import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App launches to Welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QcashApp());

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
