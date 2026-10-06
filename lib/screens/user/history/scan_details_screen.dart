import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../models/scan_history_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

class ScanDetailsScreen extends StatelessWidget {
  const ScanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! ScanHistoryModel) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Scan Details')),
        body: const Center(
          child: Text(
            'Scan details are not available.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    final scan = arguments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Scan Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(scan),

              const SizedBox(height: 16),

              _buildConfidenceCard(scan),

              const SizedBox(height: 16),

              _buildDescriptionCard(scan),

              const SizedBox(height: 16),

              _buildScanInformation(scan),

              const SizedBox(height: 16),

              _buildDisposalCard(scan),

              const SizedBox(height: 24),

              AppButton(
                text: 'Scan Again',
                icon: Icons.document_scanner_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.scan);
                },
              ),

              const SizedBox(height: 12),

              AppButton(
                text: 'Back to History',
                icon: Icons.history_rounded,
                outlined: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ScanHistoryModel scan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            scan.recyclable
                ? AppColors.primaryLight
                : Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              scan.recyclable
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : Colors.orange.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: scan.recyclable ? AppColors.primary : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              scan.recyclable ? Icons.recycling_rounded : Icons.warning_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            scan.wasteName,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 5),

          Text(scan.category, style: AppTextStyles.bodyMedium),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: scan.recyclable ? AppColors.surface : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              scan.recyclable ? '✓ Recyclable' : '⚠ Special Disposal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scan.recyclable ? AppColors.primary : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(ScanHistoryModel scan) {
    return _buildCard(
      title: 'AI Confidence',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Classification confidence',
                style: AppTextStyles.bodyMedium,
              ),
              Text(scan.confidencePercentage, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: scan.confidence,
              minHeight: 9,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ScanHistoryModel scan) {
    return _buildCard(
      title: 'Description',
      icon: Icons.info_outline_rounded,
      child: Text(scan.description, style: AppTextStyles.bodyMedium),
    );
  }

  Widget _buildScanInformation(ScanHistoryModel scan) {
    return _buildCard(
      title: 'Scan Information',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _buildInfoRow('Date', scan.date, Icons.calendar_today_outlined),
          const SizedBox(height: 12),
          _buildInfoRow('Time', scan.time, Icons.access_time_outlined),
          const SizedBox(height: 12),
          _buildInfoRow('Category', scan.category, Icons.category_outlined),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Status',
            scan.recyclable ? 'Recyclable' : 'Special Disposal',
            scan.recyclable
                ? Icons.check_circle_outline
                : Icons.warning_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDisposalCard(ScanHistoryModel scan) {
    final instructions =
        scan.recyclable
            ? const [
              'Separate the item from general waste.',
              'Clean the item if required.',
              'Place it in the appropriate recycling bin.',
              'Follow your local recycling guidelines.',
            ]
            : const [
              'Do not place this item in regular recycling bins.',
              'Keep it separate from household waste.',
              'Take it to an appropriate collection facility.',
              'Follow local special-waste disposal guidelines.',
            ];

    return _buildCard(
      title: 'Disposal Guide',
      icon: Icons.eco_outlined,
      child: Column(
        children: List.generate(instructions.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == instructions.length - 1 ? 0 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    instructions[index],
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppTextStyles.bodySmall)),
        Text(value, style: AppTextStyles.labelMedium),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
