import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recycle_app/app/routes.dart';
import 'package:recycle_app/constants/app_routes.dart';
import 'package:recycle_app/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Route Guard and Navigation Tests', () {
    testWidgets(
        'Non-admin user accessing admin dashboard sees Administrator Access Required',
        (WidgetTester tester) async {
      final auth = AuthService.instance;
      await auth.init(force: true);
      // Ensure role is customer
      await auth.login(
        email: 'customer@eco.com',
        password: 'pass',
        role: 'user',
      );
      expect(auth.isAdmin, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.roleSelection,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Attempt to navigate to admin dashboard via navigator
      final BuildContext context = tester.element(find.byType(Navigator));
      Navigator.pushNamed(context, AppRoutes.adminDashboard);
      await tester.pumpAndSettle();

      expect(find.text('Administrator Access Required'), findsOneWidget);
      expect(find.text('Return to Login'), findsOneWidget);
    });

    testWidgets('Admin user successfully accesses admin dashboard',
        (WidgetTester tester) async {
      final auth = AuthService.instance;
      await auth.init(force: true);
      await auth.login(
        email: 'admin@gmail.com',
        password: 'admin@123',
        role: 'admin',
      );
      expect(auth.isAdmin, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.roleSelection,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(Navigator));
      Navigator.pushNamed(context, AppRoutes.adminDashboard);
      await tester.pumpAndSettle();

      expect(find.text('Administrator Access Required'), findsNothing);
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
    });
  });
}

