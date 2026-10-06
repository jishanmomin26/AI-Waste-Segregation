import 'package:flutter/material.dart';

import '../constants/app_routes.dart';

// Splash & Authentication
import '../screens/splash/splash_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

// User
import '../screens/user/user_main_screen.dart';

// User - Scan
import '../screens/user/scan/scan_screen.dart';
import '../screens/user/scan/camera_screen.dart';
import '../screens/user/scan/image_preview_screen.dart';

// User - Results
import '../screens/user/results/result_screen.dart';

// User - History
import '../screens/user/history/scan_history_screen.dart';
import '../screens/user/history/scan_details_screen.dart';

// User - Locations
import '../screens/user/locations/recycling_locations_screen.dart';
import '../screens/user/locations/location_details_screen.dart';

// User - Learn
import '../screens/user/learn/learn_screen.dart';
import '../screens/user/learn/learning_details_screen.dart';

// User - Achievements
import '../screens/user/achievements/achievements_screen.dart';

// User - Notifications
import '../screens/user/notifications/notifications_screen.dart';

// User - Profile
import '../screens/user/profile/profile_screen.dart';
import '../screens/user/profile/edit_profile_screen.dart';

// Admin
import '../screens/admin/admin_main_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==================================================
      // SPLASH & AUTHENTICATION
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
      // USER
      // ==================================================

      case AppRoutes.userMain:
        return MaterialPageRoute(
          builder: (_) => const UserMainScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - SCAN
      // ==================================================

      case AppRoutes.scan:
        return MaterialPageRoute(
          builder: (_) => const ScanScreen(),
          settings: settings,
        );

      case AppRoutes.camera:
        return MaterialPageRoute(
          builder: (_) => const CameraScreen(),
          settings: settings,
        );

      case AppRoutes.imagePreview:
        return MaterialPageRoute(
          builder: (_) => const ImagePreviewScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - RESULTS
      // ==================================================

      case AppRoutes.result:
        return MaterialPageRoute(
          builder: (_) => const ResultScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - HISTORY
      // ==================================================

      case AppRoutes.history:
        return MaterialPageRoute(
          builder: (_) => const ScanHistoryScreen(),
          settings: settings,
        );

      case AppRoutes.scanDetails:
        return MaterialPageRoute(
          builder: (_) => const ScanDetailsScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - RECYCLING LOCATIONS
      // ==================================================

      case AppRoutes.locations:
        return MaterialPageRoute(
          builder: (_) => const RecyclingLocationsScreen(),
          settings: settings,
        );

      case AppRoutes.locationDetails:
        return MaterialPageRoute(
          builder: (_) => const LocationDetailsScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - LEARN
      // ==================================================

      case AppRoutes.learn:
        return MaterialPageRoute(
          builder: (_) => const LearnScreen(),
          settings: settings,
        );

      case AppRoutes.learningDetails:
        return MaterialPageRoute(
          builder: (_) => const LearningDetailsScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - ACHIEVEMENTS
      // ==================================================

      case AppRoutes.achievements:
        return MaterialPageRoute(
          builder: (_) => const AchievementsScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - NOTIFICATIONS
      // ==================================================

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - PROFILE
      // ==================================================

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );

      // ==================================================
      // USER - SETTINGS
      // ==================================================

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const _SettingsPlaceholderScreen(),
          settings: settings,
        );

      // ==================================================
      // ADMIN
      // ==================================================

      case AppRoutes.adminMain:
        return MaterialPageRoute(
          builder: (_) => const AdminMainScreen(),
          settings: settings,
        );

      // ==================================================
      // DEFAULT
      // ==================================================

      default:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
    }
  }
}

// ============================================================
// TEMPORARY SETTINGS PLACEHOLDER
// ============================================================

class _SettingsPlaceholderScreen extends StatelessWidget {
  const _SettingsPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings will be available here.')),
    );
  }
}
