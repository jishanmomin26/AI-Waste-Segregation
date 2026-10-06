import 'package:flutter/material.dart';

import '../../../models/scan_history_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ScanRecordDetailsScreen extends StatelessWidget {
  const ScanRecordDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? argument = ModalRoute.of(context)?.settings.arguments;

    final ScanHistoryModel? scan =
        argument is ScanHistoryModel ? argument : null;

    if (scan == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Scan Details')),
        body: const Center(child: Text('Scan information is not available.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Scan Details'),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // ==================================================
          // RESULT HEADER
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
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  scan.wasteName,
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 5),

                Text(scan.category, style: AppTextStyles.bodyMedium),

                const SizedBox(height: 13),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        scan.recyclable
                            ? AppColors.primaryLight
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    scan.recyclable ? 'Recyclable' : 'Special Handling',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          scan.recyclable
                              ? AppColors.primary
                              : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ==================================================
          // AI RESULT
          // ==================================================
          Text('AI Detection', style: AppTextStyles.heading3),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Confidence', style: AppTextStyles.bodyMedium),
                    Text(
                      scan.confidencePercentage,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: scan.confidence,
                    minHeight: 9,
                    backgroundColor: AppColors.primaryLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    scan.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ==================================================
          // SCAN INFORMATION
          // ==================================================
          Text('Scan Information', style: AppTextStyles.heading3),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.category_outlined,
                  title: 'Category',
                  value: scan.category,
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  value: scan.date,
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  title: 'Time',
                  value: scan.time,
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.verified_outlined,
                  title: 'Confidence',
                  value: scan.confidencePercentage,
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.recycling_rounded,
                  title: 'Disposal Type',
                  value: scan.recyclable ? 'Recyclable' : 'Special Handling',
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ==================================================
          // DISPOSAL INFORMATION
          // ==================================================
          Text('Disposal Information', style: AppTextStyles.heading3),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 23,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    scan.recyclable
                        ? 'This item can be recycled. Make sure it is clean and properly separated before placing it in the appropriate recycling stream.'
                        : 'This item requires special handling. Do not place it in regular household recycling unless your local facility specifically accepts it.',
                    style: AppTextStyles.bodyMedium,
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
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
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
        Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.titleSmall,
          ),
        ),
      ],
    );
  }
}
