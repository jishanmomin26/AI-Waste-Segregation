import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_scans.dart';
import '../../../data/dummy_users.dart';
import '../../../data/dummy_waste.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalUsers = DummyUsers.users.length;
    final totalScans = DummyScans.scans.length;
    final totalCategories = DummyWaste.categories.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.adminNotifications);
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 22),
            Text('Overview', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildStatsGrid(totalUsers, totalScans, totalCategories),
            const SizedBox(height: 24),
            _buildSectionHeader('Management', 'View all', () {}),
            const SizedBox(height: 12),
            _buildManagementGrid(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Quick Actions', null, null),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildInfoBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage your recycling platform from one place.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int users, int scans, int categories) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.people_alt_outlined,
                '$users',
                'Users',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.document_scanner_outlined,
                '$scans',
                'Scans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.recycling_outlined,
                '$categories',
                'Categories',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(Icons.location_on_outlined, '4', 'Centers'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String title) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value, style: AppStylesNumber.value),
          const SizedBox(height: 3),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String? action,
    VoidCallback? onTap,
  ) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.heading3)),
        if (action != null && onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    final items = [
      (Icons.people_outline_rounded, 'Users', AppRoutes.users),
      (Icons.recycling_outlined, 'Waste', AppRoutes.wasteManagement),
      (Icons.document_scanner_outlined, 'Scans', AppRoutes.scanRecords),
      (Icons.location_on_outlined, 'Centers', AppRoutes.recyclingCenters),
      (Icons.analytics_outlined, 'Analytics', AppRoutes.analytics),
      (
        Icons.notifications_none_rounded,
        'Notifications',
        AppRoutes.adminNotifications,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, item.$3);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1, color: AppColors.primary, size: 22),
                ),
                const SizedBox(height: 11),
                Text(item.$2, style: AppTextStyles.titleSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAction(
            context,
            Icons.add_box_outlined,
            'Add Waste',
            AppRoutes.addWasteCategory,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickAction(
            context,
            Icons.add_location_alt_outlined,
            'Add Center',
            AppRoutes.addCenter,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 19, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Admin dashboard currently uses demo data. '
              'Backend and database integration can be connected later.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppStylesNumber {
  static const TextStyle value = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
}
