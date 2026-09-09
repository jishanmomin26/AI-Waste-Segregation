import 'package:flutter/material.dart';

import '../../../data/dummy_achievements.dart';
import '../../../models/achievement_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = DummyAchievements.achievements;

    final unlockedCount = achievements.where((item) => item.unlocked).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSummaryCard(achievements.length, unlockedCount),

            const SizedBox(height: 20),

            const Text('Your Achievements', style: AppTextStyles.heading3),

            const SizedBox(height: 12),

            ...achievements.map(
              (achievement) => _buildAchievementCard(achievement),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int total, int unlocked) {
    final progress = total == 0 ? 0.0 : unlocked / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),

          const SizedBox(height: 14),

          const Text('Keep Going!', style: AppTextStyles.heading3),

          const SizedBox(height: 5),

          Text(
            '$unlocked of $total achievements unlocked',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${(progress * 100).round()}% completed',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAchievementIcon(achievement),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    if (achievement.unlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Unlocked',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(achievement.description, style: AppTextStyles.bodySmall),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          minHeight: 7,
                          backgroundColor: AppColors.border,
                          color:
                              achievement.unlocked
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.55),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      '${achievement.currentCount}/${achievement.requiredCount}',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  achievement.progressPercentage,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon(AchievementModel achievement) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color:
            achievement.unlocked
                ? AppColors.primaryLight
                : AppColors.background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color:
              achievement.unlocked
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.border,
        ),
      ),
      child: Icon(
        _getIcon(achievement.icon),
        color:
            achievement.unlocked ? AppColors.primary : AppColors.textSecondary,
        size: 28,
      ),
    );
  }

  IconData _getIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'scan':
        return Icons.document_scanner_rounded;

      case 'eco':
        return Icons.eco_rounded;

      case 'recycling':
        return Icons.recycling_rounded;

      case 'shield':
        return Icons.shield_rounded;

      case 'star':
        return Icons.star_rounded;

      case 'trophy':
        return Icons.emoji_events_rounded;

      case 'plastic':
        return Icons.local_drink_outlined;

      case 'battery':
        return Icons.battery_alert_rounded;

      default:
        return Icons.workspace_premium_rounded;
    }
  }
}
