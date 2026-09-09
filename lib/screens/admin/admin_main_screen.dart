import 'package:flutter/material.dart';

import '../../constants/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/navigation/admin_bottom_nav.dart';
import 'dashboard/admin_dashboard_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const AdminDashboardScreen(),
      const _UsersTab(),
      const _ScansTab(),
      const _ProfileTab(),
    ];
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onDestinationSelected: _onNavigationChanged,
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return _AdminTabPlaceholder(
      title: 'Users',
      icon: Icons.people_rounded,
      description: 'Manage registered users and view their activity.',
      buttonText: 'Manage Users',
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.users);
      },
    );
  }
}

class _ScansTab extends StatelessWidget {
  const _ScansTab();

  @override
  Widget build(BuildContext context) {
    return _AdminTabPlaceholder(
      title: 'Scan Records',
      icon: Icons.document_scanner_rounded,
      description: 'Review waste scanning activity and AI detection results.',
      buttonText: 'View Scan Records',
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.scanRecords);
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return _AdminTabPlaceholder(
      title: 'Admin Profile',
      icon: Icons.admin_panel_settings_rounded,
      description: 'View your administrator profile and account settings.',
      buttonText: 'View Admin Profile',
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.adminProfile);
      },
      secondaryButtonText: 'Admin Settings',
      onSecondaryPressed: () {
        Navigator.pushNamed(context, AppRoutes.adminSettings);
      },
    );
  }
}

class _AdminTabPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const _AdminTabPlaceholder({
    required this.title,
    required this.icon,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 42, color: AppColors.primary),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              if (secondaryButtonText != null &&
                  onSecondaryPressed != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: onSecondaryPressed,
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(secondaryButtonText!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
