import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recycle_app/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Tests', () {
    test('Initial unauthenticated state', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      expect(auth.isLoggedIn, isFalse);
      expect(auth.userRole, 'user');
      expect(auth.isAdmin, isFalse);
    });

    test('Login as customer persists session and role', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final success = await auth.login(
        email: 'test@user.com',
        password: 'password123',
        role: 'user',
      );
      expect(success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isAdmin, isFalse);
      expect(auth.currentUser.email, 'test@user.com');

      // Verify SharedPreferences persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('auth_is_logged_in'), isTrue);
      expect(prefs.getString('auth_role'), 'user');
    });

    test('Login as admin persists admin role', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);

      final success = await auth.login(
        email: 'admin@gmail.com',
        password: 'admin@123',
        role: 'admin',
      );
      expect(success, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isAdmin, isTrue);
      expect(auth.currentUser.email, 'admin@gmail.com');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_role'), 'admin');
    });

    test('Session restoration across app restarts', () async {
      // Simulate stored session from prior app run
      SharedPreferences.setMockInitialValues({
        'auth_is_logged_in': true,
        'auth_role': 'user',
        'auth_user_profile':
            '{"name":"Restored Recycler","email":"restored@eco.com","phone":"+123456789","location":"Austin, TX","joinedDate":"January 2026","totalScans":5,"ecoPoints":250,"successfulScans":4}',
      });

      final auth = AuthService.instance;
      await auth.init(force: true);

      expect(auth.isLoggedIn, isTrue);
      expect(auth.userRole, 'user');
      expect(auth.currentUser.name, 'Restored Recycler');
      expect(auth.currentUser.ecoPoints, 250);
      expect(auth.currentUser.totalScans, 5);
    });

    test('Logout clears session state and preferences', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);
      await auth.login(email: 'user@eco.com', password: 'pass', role: 'user');
      expect(auth.isLoggedIn, isTrue);

      await auth.logout();
      expect(auth.isLoggedIn, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('auth_is_logged_in') ?? false, isFalse);
    });

    test('Update profile updates currentUser and persists', () async {
      final auth = AuthService.instance;
      await auth.init(force: true);
      await auth.login(email: 'user@eco.com', password: 'pass', role: 'user');

      await auth.updateProfile(
        name: 'Updated Name',
        email: 'user@eco.com',
        phone: '+1 555-0199',
        location: 'Seattle, WA',
      );
      expect(auth.currentUser.name, 'Updated Name');
      expect(auth.currentUser.location, 'Seattle, WA');

      final prefs = await SharedPreferences.getInstance();
      final profileStr = prefs.getString('auth_user_profile');
      expect(profileStr, contains('Updated Name'));
    });
  });
}

