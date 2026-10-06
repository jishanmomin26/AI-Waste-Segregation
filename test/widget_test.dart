import 'package:flutter_test/flutter_test.dart';

import 'package:recycle_app/app/app.dart';

void main() {
  testWidgets('Reccly app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const RecycleApp());

    expect(find.text('Reccly'), findsOneWidget);
  });
}
