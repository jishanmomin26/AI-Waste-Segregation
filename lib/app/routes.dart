import 'package:flutter/material.dart';

import '../constants/app_routes.dart';

// Splash & Authentication
import '../screens/splash/splash_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

// User Screens
import '../screens/user/user_main_screen.dart';
import '../screens/user/scan/scan_screen.dart';
import '../screens/user/scan/camera_screen.dart';
import '../screens/user/scan/image_preview_screen.dart';
import '../screens/user/results/result_screen.dart';
import '../screens/user/history/scan_history_screen.dart';
import '../screens/user/history/scan_details_screen.dart';
import '../screens/user/locations/recycling_locations_screen.dart';
import '../screens/user/locations/location_details_screen.dart';
import '../screens/user/learn/learn_screen.dart';
import '../screens/user/learn/learning_details_screen.dart';
import '../screens/user/achievements/achievements_screen.dart';
import '../screens/user/notifications/notifications_screen.dart';
import '../screens/user/profile/profile_screen.dart';
import '../screens/user/profile/edit_profile_screen.dart';
import '../screens/user/profile/settings_screen.dart';

// Admin Screens
import '../screens/admin/admin_main_screen.dart';
import '../screens/admin/dashboard/admin_dashboard_screen.dart';
import '../screens/admin/users/users_screen.dart';
import '../screens/admin/users/user_details_screen.dart';
import '../screens/admin/waste/waste_management_screen.dart';
import '../screens/admin/waste/add_waste_category_screen.dart';
import '../screens/admin/waste/edit_waste_category_screen.dart';
import '../screens/admin/scans/scan_records_screen.dart';
import '../screens/admin/scans/scan_record_details_screen.dart';
import '../screens/admin/centers/recycling_centers_screen.dart';
import '../screens/admin/centers/add_center_screen.dart';
import '../screens/admin/centers/center_details_screen.dart';
import '../screens/admin/analytics/analytics_screen.dart';
import '../screens/admin/notifications/admin_notifications_screen.dart';
import '../screens/admin/profile/admin_profile_screen.dart';
import '../screens/admin/profile/admin_settings_screen.dart';

import '../services/auth_service.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==================================================
      // SPLASH & AUTHENTICATION (PUBLIC)
      // ==================================================

      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      // ==================================================
      // CUSTOMER (ROLE GUARD: USER ONLY)
      // ==================================================

      case AppRoutes.userMain:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const UserMainScreen()),
          settings: settings,
        );

      case AppRoutes.scan:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const ScanScreen()),
          settings: settings,
        );

      case AppRoutes.camera:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const CameraScreen()),
          settings: settings,
        );

      case AppRoutes.imagePreview:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const ImagePreviewScreen()),
          settings: settings,
        );

      case AppRoutes.result:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const ResultScreen()),
          settings: settings,
        );

      case AppRoutes.history:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const ScanHistoryScreen()),
          settings: settings,
        );

      case AppRoutes.scanDetails:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const ScanDetailsScreen()),
          settings: settings,
        );

      case AppRoutes.locations:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const RecyclingLocationsScreen()),
          settings: settings,
        );

      case AppRoutes.locationDetails:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const LocationDetailsScreen()),
          settings: settings,
        );

      case AppRoutes.learn:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const LearnScreen()),
          settings: settings,
        );

      case AppRoutes.learningDetails:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const LearningDetailsScreen()),
          settings: settings,
        );

      case AppRoutes.achievements:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const AchievementsScreen()),
          settings: settings,
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const NotificationsScreen()),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const ProfileScreen()),
          settings: settings,
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const EditProfileScreen()),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => _guardCustomer(const SettingsScreen()),
          settings: settings,
        );

      // ==================================================
      // ADMIN (ROLE GUARD: ADMIN ONLY)
      // ==================================================

      case AppRoutes.adminMain:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AdminMainScreen()),
          settings: settings,
        );

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AdminDashboardScreen()),
          settings: settings,
        );

      case AppRoutes.users:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const UsersScreen()),
          settings: settings,
        );

      case AppRoutes.userDetails:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const UserDetailsScreen()),
          settings: settings,
        );

      case AppRoutes.wasteManagement:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const WasteManagementScreen()),
          settings: settings,
        );

      case AppRoutes.addWasteCategory:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AddWasteCategoryScreen()),
          settings: settings,
        );

      case AppRoutes.editWasteCategory:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const EditWasteCategoryScreen()),
          settings: settings,
        );

      case AppRoutes.scanRecords:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const ScanRecordsScreen()),
          settings: settings,
        );

      case AppRoutes.scanRecordDetails:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const ScanRecordDetailsScreen()),
          settings: settings,
        );

      case AppRoutes.recyclingCenters:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const RecyclingCentersScreen()),
          settings: settings,
        );

      case AppRoutes.addCenter:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AddCenterScreen()),
          settings: settings,
        );

      case AppRoutes.centerDetails:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const CenterDetailsScreen()),
          settings: settings,
        );

      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AnalyticsScreen()),
          settings: settings,
        );

      case AppRoutes.adminNotifications:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AdminNotificationsScreen()),
          settings: settings,
        );

      case AppRoutes.adminProfile:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AdminProfileScreen()),
          settings: settings,
        );

      case AppRoutes.adminSettings:
        return MaterialPageRoute(
          builder: (_) => _guardAdmin(const AdminSettingsScreen()),
          settings: settings,
        );

      // ==================================================
      // DEFAULT FALLBACK
      // ==================================================

      default:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );
    }
  }

  /// Route guard that requires active customer session.
  /// Prevents admin accounts and unauthenticated sessions from accessing customer views.
  static Widget _guardCustomer(Widget destination) {
    final auth = AuthService.instance;
    if (!auth.isLoggedIn) {
      return const _UnauthenticatedAccessDeniedScreen();
    }
    if (auth.isAdmin) {
      return const _CustomerAccessDeniedToAdminScreen();
    }
    return destination;
  }

  /// Route guard that requires active administrator session.
  /// Prevents customer accounts and unauthenticated sessions from accessing admin views.
  static Widget _guardAdmin(Widget destination) {
    final auth = AuthService.instance;
    if (auth.isLoggedIn && auth.isAdmin) {
      return destination;
    }
    return const _AdminAccessDeniedScreen();
  }
}

class _AdminAccessDeniedScreen extends StatelessWidget {
  const _AdminAccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_person_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Administrator Access Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You must be signed in with an administrator account to view this section.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.roleSelection,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerAccessDeniedToAdminScreen extends StatelessWidget {
  const _CustomerAccessDeniedToAdminScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                size: 64,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer Area Only',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You are currently signed in as an Administrator. This section is restricted to customer accounts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.adminMain,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text('Return to Admin Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnauthenticatedAccessDeniedScreen extends StatelessWidget {
  const _UnauthenticatedAccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In Required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.login_rounded,
                size: 64,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Authentication Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please sign in to access your recycling account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.roleSelection,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Go to Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
