import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool scanRemindersEnabled = true;
  bool locationEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildSectionTitle('Preferences'),
          const SizedBox(height: 12),

          _buildSwitchCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Receive recycling updates and alerts',
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          const SizedBox(height: 10),

          _buildSwitchCard(
            icon: Icons.alarm_outlined,
            title: 'Scan Reminders',
            subtitle: 'Get reminders to keep recycling',
            value: scanRemindersEnabled,
            onChanged: (value) {
              setState(() {
                scanRemindersEnabled = value;
              });
            },
          ),

          const SizedBox(height: 10),

          _buildSwitchCard(
            icon: Icons.location_on_outlined,
            title: 'Location Access',
            subtitle: 'Find recycling centers near you',
            value: locationEnabled,
            onChanged: (value) {
              setState(() {
                locationEnabled = value;
              });
            },
          ),

          const SizedBox(height: 10),

          _buildSwitchCard(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Use a darker appearance',
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Dark Mode enabled for this demo.'
                        : 'Light Mode enabled.',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          _buildSectionTitle('App'),
          const SizedBox(height: 12),

          _buildActionCard(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              _showInfoDialog(
                title: 'Language',
                message:
                    'Language selection will be available in a future version.',
              );
            },
          ),

          const SizedBox(height: 10),

          _buildActionCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Manage your privacy preferences',
            onTap: () {
              _showInfoDialog(
                title: 'Privacy',
                message:
                    'Your personal information is used only within the Reccly application.',
              );
            },
          ),

          const SizedBox(height: 10),

          _buildActionCard(
            icon: Icons.info_outline_rounded,
            title: 'About Reccly',
            subtitle: 'Smart Recycling • Version 1.0.0',
            onTap: () {
              _showInfoDialog(
                title: 'About Reccly',
                message:
                    'Reccly is a smart recycling and waste-management application that helps users identify waste, understand disposal methods and recycle responsibly.',
              );
            },
          ),

          const SizedBox(height: 28),

          _buildSectionTitle('Account'),
          const SizedBox(height: 12),

          _buildActionCard(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            subtitle: 'Sign out from your account',
            iconColor: AppColors.error,
            onTap: _showLogoutDialog,
          ),

          const SizedBox(height: 32),

          Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Reccly',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 3),
              Text('Smart Recycling', style: AppTextStyles.bodySmall),
              const SizedBox(height: 3),
              Text('Version 1.0.0', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDark),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildIconBox(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final Color color = iconColor ?? AppColors.primary;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildIconBox(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 4),
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

  Widget _buildIconBox(IconData icon, {Color color = AppColors.primary}) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  void _showInfoDialog({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/role-selection',
                  (route) => false,
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
