import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/scan_history_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSessionCheck();
  }

  Future<void> _startSessionCheck() async {
    // Initialize services concurrently
    await Future.wait([
      AuthService.instance.init(),
      ScanHistoryService.instance.init(),
    ]);

    // Ensure splash is visible for at least 1.5 seconds for branding
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final auth = AuthService.instance;
      if (auth.isLoggedIn) {
        if (auth.isAdmin) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.userMain);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              Text('Reccly', style: AppTextStyles.heading1),

              const SizedBox(height: 6),

              Text('Smart Recycling', style: AppTextStyles.bodyMedium),

              const SizedBox(height: 28),

              Text(
                'Smart waste management for a cleaner future',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
