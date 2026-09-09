import 'package:flutter/material.dart';

import '../../models/scan_history_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ScanRecordTile extends StatelessWidget {
  final ScanHistoryModel scan;
  final VoidCallback onTap;

  const ScanRecordTile({super.key, required this.scan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scan.wasteName, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 4),
                    Text(scan.category, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(scan.date, style: AppTextStyles.caption),
                        const SizedBox(width: 9),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(scan.time, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          scan.recyclable
                              ? AppColors.primaryLight
                              : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      scan.recyclable ? 'Recyclable' : 'Special',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color:
                            scan.recyclable
                                ? AppColors.primary
                                : AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    scan.confidencePercentage,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
