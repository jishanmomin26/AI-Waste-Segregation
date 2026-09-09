import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? argument = ModalRoute.of(context)?.settings.arguments;

    final UserModel? user = argument is UserModel ? argument : null;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('User Details')),
        body: const Center(child: Text('User information is not available.')),
      );
    }

    final String firstLetter =
        user.name.trim().isNotEmpty ? user.name.trim()[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: AppColors.background,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // ==================================================
          // PROFILE HEADER
          // ==================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(user.name, style: AppTextStyles.heading2),

                const SizedBox(height: 5),

                Text(user.email, style: AppTextStyles.bodyMedium),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        user.active
                            ? AppColors.primaryLight
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.active ? 'Active User' : 'Inactive User',
                    style: TextStyle(
                      color:
                          user.active
                              ? AppColors.primary
                              : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ==================================================
          // ACTIVITY STATS
          // ==================================================
          Text('Activity', style: AppTextStyles.heading3),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _DetailStat(
                  icon: Icons.recycling_rounded,
                  value: '${user.totalScans}',
                  label: 'Total Scans',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailStat(
                  icon: Icons.eco_outlined,
                  value: '${user.ecoPoints}',
                  label: 'Eco Points',
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================
          // PERSONAL INFORMATION
          // ==================================================
          Text('Personal Information', style: AppTextStyles.heading3),

          const SizedBox(height: 12),

          _InformationCard(
            children: [
              _InformationRow(
                icon: Icons.email_outlined,
                title: 'Email',
                value: user.email,
              ),
              const Divider(height: 24),
              _InformationRow(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: user.phone,
              ),
              const Divider(height: 24),
              _InformationRow(
                icon: Icons.location_on_outlined,
                title: 'Location',
                value: user.location,
              ),
              const Divider(height: 24),
              _InformationRow(
                icon: Icons.calendar_today_outlined,
                title: 'Joined',
                value: user.joinedDate,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================
          // ACCOUNT STATUS
          // ==================================================
          Text('Account Status', style: AppTextStyles.heading3),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color:
                  user.active ? AppColors.primaryLight : AppColors.background,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  user.active
                      ? Icons.check_circle_rounded
                      : Icons.pause_circle_outline_rounded,
                  color:
                      user.active ? AppColors.primary : AppColors.textSecondary,
                  size: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.active
                            ? 'Account is active'
                            : 'Account is inactive',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.active
                            ? 'This user can currently use the Reccly application.'
                            : 'This user account is currently inactive.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DETAIL STAT
// ============================================================

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DetailStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ============================================================
// INFORMATION CARD
// ============================================================

class _InformationCard extends StatelessWidget {
  final List<Widget> children;

  const _InformationCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

// ============================================================
// INFORMATION ROW
// ============================================================

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelMedium),
              const SizedBox(height: 3),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
