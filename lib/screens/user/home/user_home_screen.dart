import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_profile.dart';
import '../../../data/dummy_scans.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DummyProfile.currentUser;
    final recentScans = DummyScans.scans.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _buildHeader(context, user.name),
              const SizedBox(height: 24),
              _buildHeroCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Quick Actions', 'Explore', () {
                Navigator.pushNamed(context, AppRoutes.learn);
              }),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildEcoStats(user),
              const SizedBox(height: 24),
              _buildSectionTitle('Recent Scans', 'View All', () {
                Navigator.pushNamed(context, AppRoutes.history);
              }),
              const SizedBox(height: 12),
              ...recentScans.map(
                (scan) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRecentScan(context, scan),
                ),
              ),
              const SizedBox(height: 14),
              _buildLearningBanner(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good day 👋', style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(userName, style: AppTextStyles.heading3),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.notifications);
          },
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Give your waste\nanother life.',
            style: TextStyle(
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Scan an item and discover the right way to dispose of it.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.scan);
              },
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(
                'Scan Waste',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String actionText,
    VoidCallback onAction,
  ) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.heading3)),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            actionText,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.location_on_outlined,
            title: 'Find Center',
            subtitle: 'Nearby recycling',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.locations);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.menu_book_outlined,
            title: 'Learn',
            subtitle: 'Recycling tips',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.learn);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            Text(title, style: AppTextStyles.titleSmall),
            const SizedBox(height: 3),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoStats(user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.eco_rounded,
              '${user.ecoPoints}',
              'Eco Points',
            ),
          ),
          Container(width: 1, height: 44, color: AppColors.border),
          Expanded(
            child: _buildStatItem(
              Icons.camera_alt_outlined,
              '${user.totalScans}',
              'Total Scans',
            ),
          ),
          Container(width: 1, height: 44, color: AppColors.border),
          Expanded(
            child: _buildStatItem(
              Icons.check_circle_outline_rounded,
              '${user.successfulScans}',
              'Recycled',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 21, color: AppColors.primary),
        const SizedBox(height: 7),
        Text(value, style: AppTextStyles.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildRecentScan(BuildContext context, scan) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.scanDetails, arguments: scan);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.recycling_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.wasteName, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 4),
                  Text(scan.category, style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  scan.confidencePercentage,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(scan.date, style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningBanner(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.learn);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Become a better recycler',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Learn simple ways to reduce waste.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
