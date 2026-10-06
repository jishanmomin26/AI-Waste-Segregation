import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_profile.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DummyProfile.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: AppTextStyles.heading2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, color: Colors.white, size: 17),
                      SizedBox(width: 6),
                      Text(
                        'Eco Recycler',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.document_scanner_outlined,
                  value: '${user.totalScans}',
                  label: 'Total Scans',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.eco_outlined,
                  value: '${user.ecoPoints}',
                  label: 'Eco Points',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  icon: Icons.recycling_rounded,
                  value: '${user.successfulScans}',
                  label: 'Recycled',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _sectionTitle('Personal Information'),
          const SizedBox(height: 12),

          _infoCard(
            icon: Icons.person_outline_rounded,
            title: 'Name',
            value: user.name,
          ),

          const SizedBox(height: 10),

          _infoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user.email,
          ),

          const SizedBox(height: 10),

          _infoCard(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: user.phone,
          ),

          const SizedBox(height: 10),

          _infoCard(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: user.location,
          ),

          const SizedBox(height: 10),

          _infoCard(
            icon: Icons.calendar_month_outlined,
            title: 'Joined',
            value: user.joinedDate,
          ),

          const SizedBox(height: 28),

          _sectionTitle('Account'),
          const SizedBox(height: 12),

          _menuCard(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),

          const SizedBox(height: 10),

          _menuCard(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            subtitle: 'View your recycling achievements',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.achievements);
            },
          ),

          const SizedBox(height: 10),

          _menuCard(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'View your latest updates',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
          ),

          const SizedBox(height: 10),

          _menuCard(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Manage your app preferences',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.accent),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Every scan is a small step toward a cleaner and greener future.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDark),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 23),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall),
                const SizedBox(height: 3),
                Text(value, style: AppTextStyles.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _iconBox(icon),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 3),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.primary, size: 21),
    );
  }
}
