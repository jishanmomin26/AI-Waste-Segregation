import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:recycle_app/app/routes.dart';
import 'package:recycle_app/config/admin_config.dart';
import 'package:recycle_app/constants/app_routes.dart';
import 'package:recycle_app/models/scan_history_model.dart';
import 'package:recycle_app/services/auth_service.dart';
import 'package:recycle_app/services/scan_history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Scenario A: Customer Registration, Login & Session Persistence', () {
    test('Registers customer with actual email and name, matching login restores identity', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      // 1. Register with new user credentials
      final regResult = await auth.register(
        name: 'Samantha Ray',
        email: 'samantha.ray@example.com',
        password: 'securePass123',
      );
      expect(regResult.success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isAdmin, isFalse);

      // Verify source of truth identity
      expect(auth.currentUser.email, 'samantha.ray@example.com');
      expect(auth.currentUser.name, 'Samantha Ray');
      expect(auth.currentUser.displayName, 'Samantha Ray');
      expect(auth.currentUser.name, isNot('Hammad'));

      // 2. Logout clears session and in-memory profile
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.currentUser.email, isEmpty);

      // 3. Login with registered credentials
      final loginResult = await auth.login(
        email: 'samantha.ray@example.com',
        password: 'securePass123',
        role: 'user',
      );
      expect(loginResult.success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentUser.email, 'samantha.ray@example.com');
      expect(auth.currentUser.name, 'Samantha Ray');

      // 4. Verify cold process restart restores the session
      await auth.init(force: true);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentUser.email, 'samantha.ray@example.com');
      expect(auth.currentUser.name, 'Samantha Ray');
    });

    test('Unregistered customer login fails and does not create or substitute account', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final result = await auth.login(
        email: 'ghost.user@unknown.com',
        password: 'anyPassword',
        role: 'user',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('No registered account found'));
      expect(auth.isLoggedIn, isFalse);
    });

    test('Customer login with wrong password fails cleanly', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      await auth.register(
        name: 'David Miller',
        email: 'david@test.com',
        password: 'correctPassword',
      );
      await auth.logout();

      final result = await auth.login(
        email: 'david@test.com',
        password: 'incorrectPassword',
        role: 'user',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Incorrect password'));
      expect(auth.isLoggedIn, isFalse);
    });
  });

  group('Scenario B: Admin Authentication & Strict Separation', () {
    test('Admin logs in with authorized credentials and persists admin role', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final result = await auth.login(
        email: 'admin@gmail.com',
        password: 'admin@123',
        role: 'admin',
      );

      expect(result.success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isAdmin, isTrue);
      expect(auth.currentUser.email, 'admin@gmail.com');
      expect(auth.currentUser.name, 'Reccly Admin');

      // Verify restart restores admin
      await auth.init(force: true);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isAdmin, isTrue);
      expect(auth.currentUser.email, 'admin@gmail.com');
    });

    test('Customer cannot log in through Admin Portal', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      await auth.register(
        name: 'Normal User',
        email: 'normal@test.com',
        password: 'password123',
      );
      await auth.logout();

      final result = await auth.login(
        email: 'normal@test.com',
        password: 'password123',
        role: 'admin',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Administrator access'));
      expect(auth.isLoggedIn, isFalse);
    });

    test('Admin cannot log in through Customer Portal', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final result = await auth.login(
        email: 'admin@gmail.com',
        password: 'admin@123',
        role: 'user',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Admin Portal'));
      expect(auth.isLoggedIn, isFalse);
    });

    test('Admin login with incorrect password fails and denies access', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final result = await auth.login(
        email: AdminConfig.authorizedAdminEmail,
        password: 'wrongAdminPassword',
        role: 'admin',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Invalid administrator credentials'));
      expect(auth.isLoggedIn, isFalse);
      expect(auth.isAdmin, isFalse);
    });

    test('Unauthorized email cannot log in via Admin Portal', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final result = await auth.login(
        email: 'intruder@domain.com',
        password: 'admin@123',
        role: 'admin',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Administrator access denied'));
      expect(auth.isLoggedIn, isFalse);
    });

    test('Public registration with administrator email is strictly rejected', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final result = await auth.register(
        name: 'Impostor Admin',
        email: AdminConfig.authorizedAdminEmail,
        password: 'anyPassword123',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Cannot register with an administrator email address'));
      expect(auth.isLoggedIn, isFalse);
    });

    test('Customer registration with "Admin" name never grants admin privileges', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final result = await auth.register(
        name: 'Super Admin Person',
        email: 'customer.admin.name@test.com',
        password: 'password123',
      );

      expect(result.success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isAdmin, isFalse);
      expect(auth.role, 'user');
    });

    test('AdminConfig cryptographic verification behaves securely', () {
      expect(AdminConfig.verifyPassword('admin@123'), isTrue);
      expect(AdminConfig.verifyPassword('wrongPassword'), isFalse);
      expect(AdminConfig.verifyPassword('adminPass'), isFalse);
      expect(AdminConfig.verifyPassword('adminPass123'), isFalse);
      expect(AdminConfig.verifyPassword(''), isFalse);
      expect(AdminConfig.isAuthorizedAdminEmail('ADMIN@GMAIL.COM'), isTrue);
      expect(AdminConfig.isAuthorizedAdminEmail('other@domain.com'), isFalse);
    });
  });

  group('Scenario C: Account Data Isolation (Customer A vs Customer B)', () {
    test('Customer B cannot see Customer A scans, points or identity', () async {
      final auth = AuthService.instance;
      final scanHistory = ScanHistoryService.instance;
      await auth.init(force: true);

      // 1. Customer A registers and adds a scan
      await auth.register(
        name: 'Alice Cooper',
        email: 'alice@example.com',
        password: 'alicePassword123',
      );
      expect(auth.currentUser.name, 'Alice Cooper');
      expect(scanHistory.scans, isEmpty);

      final aliceScan = ScanHistoryModel(
        id: 'alice_scan_01',
        wasteName: 'Alice Plastic Bottle',
        category: 'Plastic',
        confidence: 0.96,
        date: '16 October 2026',
        time: '10:00 AM',
        recyclable: true,
        description: 'Alice recyclable bottle',
      );
      await scanHistory.addScan(aliceScan);
      expect(scanHistory.scans.length, 1);
      expect(scanHistory.scans.first.wasteName, 'Alice Plastic Bottle');
      expect(auth.currentUser.ecoPoints, 70); // 50 welcome + 20 recyclable

      // 2. Customer A logs out
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(scanHistory.scans, isEmpty);

      // 3. Customer B registers
      await auth.register(
        name: 'Bob Marley',
        email: 'bob@example.com',
        password: 'bobPassword123',
      );
      expect(auth.currentUser.name, 'Bob Marley');
      expect(auth.currentUser.email, 'bob@example.com');
      expect(auth.currentUser.ecoPoints, 50); // Fresh welcome points

      // 4. Verify Customer B starts with an empty scan history (isolated from Alice)
      expect(scanHistory.scans, isEmpty);
      expect(scanHistory.scans.any((s) => s.id == 'alice_scan_01'), isFalse);

      // 5. Customer B logs out and Alice logs back in
      await auth.logout();
      await auth.login(
        email: 'alice@example.com',
        password: 'alicePassword123',
        role: 'user',
      );

      // Alice's data is restored
      expect(auth.currentUser.name, 'Alice Cooper');
      expect(auth.currentUser.email, 'alice@example.com');
      expect(auth.currentUser.ecoPoints, 70);
      expect(scanHistory.scans.length, 1);
      expect(scanHistory.scans.first.wasteName, 'Alice Plastic Bottle');
    });
  });

  group('Route Guarding Bi-directional Protection', () {
    testWidgets('Admin user attempting to open customer area sees restriction',
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
      Navigator.pushNamed(context, AppRoutes.userMain);
      await tester.pumpAndSettle();

      expect(find.text('Customer Area Only'), findsOneWidget);
      expect(find.text('Return to Admin Dashboard'), findsOneWidget);
    });

    testWidgets('Customer user attempting to open admin area sees restriction',
        (WidgetTester tester) async {
      final auth = AuthService.instance;
      await auth.init(force: true);
      await auth.login(
        email: 'test@user.com',
        password: 'password123',
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

      final BuildContext context = tester.element(find.byType(Navigator));
      Navigator.pushNamed(context, AppRoutes.adminDashboard);
      await tester.pumpAndSettle();

      expect(find.text('Administrator Access Required'), findsOneWidget);
      expect(find.text('Return to Login'), findsOneWidget);
    });
  });
}

