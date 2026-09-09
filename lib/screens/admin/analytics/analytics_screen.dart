import 'package:flutter/material.dart';

import '../../../data/dummy_scans.dart';
import '../../../data/dummy_users.dart';
import '../../../data/dummy_waste.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  int get _totalUsers => DummyUsers.users.length;

  int get _totalScans => DummyScans.scans.length;

  int get _recyclableScans {
    return DummyScans.scans.where((scan) => scan.recyclable).length;
  }

  int get _specialScans {
    return DummyScans.scans.where((scan) => !scan.recyclable).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildOverview(),

            const SizedBox(height: 22),

            const Text(
              'Waste Category Distribution',
              style: AppTextStyles.heading3,
            ),

            const SizedBox(height: 12),

            _buildCategoryDistribution(),

            const SizedBox(height: 22),

            const Text('Scan Activity', style: AppTextStyles.heading3),

            const SizedBox(height: 12),

            _buildScanActivity(),

            const SizedBox(height: 22),

            const Text('User Engagement', style: AppTextStyles.heading3),

            const SizedBox(height: 12),

            _buildUserEngagement(),

            const SizedBox(height: 22),

            const Text('Recycling Performance', style: AppTextStyles.heading3),

            const SizedBox(height: 12),

            _buildPerformanceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _statCard(
          title: 'Total Users',
          value: '$_totalUsers',
          icon: Icons.people_alt_outlined,
        ),
        _statCard(
          title: 'Total Scans',
          value: '$_totalScans',
          icon: Icons.document_scanner_outlined,
        ),
        _statCard(
          title: 'Recyclable',
          value: '$_recyclableScans',
          icon: Icons.recycling_outlined,
        ),
        _statCard(
          title: 'Special Waste',
          value: '$_specialScans',
          icon: Icons.warning_amber_outlined,
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.heading3),
              const SizedBox(height: 2),
              Text(title, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    final categories = DummyWaste.categories;

    final total = categories.fold<int>(
      0,
      (sum, category) => sum + category.totalScans,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children:
            categories.map((category) {
              final percentage = total == 0 ? 0.0 : category.totalScans / total;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: AppTextStyles.labelMedium,
                          ),
                        ),
                        Text(
                          '${category.totalScans} scans',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(percentage * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildScanActivity() {
    final scans = DummyScans.scans;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _activityRow(
            label: 'Total scans',
            value: '${scans.length}',
            icon: Icons.document_scanner_outlined,
          ),
          const Divider(height: 24),
          _activityRow(
            label: 'Recyclable scans',
            value: '$_recyclableScans',
            icon: Icons.recycling_outlined,
          ),
          const Divider(height: 24),
          _activityRow(
            label: 'Special waste scans',
            value: '$_specialScans',
            icon: Icons.warning_amber_outlined,
          ),
          const Divider(height: 24),
          _activityRow(
            label: 'Average confidence',
            value: _averageConfidence(),
            icon: Icons.auto_awesome_outlined,
          ),
        ],
      ),
    );
  }

  Widget _activityRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.labelMedium)),
        Text(value, style: AppTextStyles.titleMedium),
      ],
    );
  }

  String _averageConfidence() {
    if (DummyScans.scans.isEmpty) {
      return '0%';
    }

    final total = DummyScans.scans.fold<double>(
      0,
      (sum, scan) => sum + scan.confidence,
    );

    final average = total / DummyScans.scans.length;

    return '${(average * 100).round()}%';
  }

  Widget _buildUserEngagement() {
    final activeUsers = DummyUsers.users.where((user) => user.active).length;

    final inactiveUsers = DummyUsers.users.where((user) => !user.active).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _engagementRow('Registered Users', _totalUsers),
          const SizedBox(height: 14),
          _engagementRow('Active Users', activeUsers),
          const SizedBox(height: 14),
          _engagementRow('Inactive Users', inactiveUsers),
        ],
      ),
    );
  }

  Widget _engagementRow(String title, int value) {
    final percentage = _totalUsers == 0 ? 0.0 : value / _totalUsers;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.labelMedium)),
            Text('$value', style: AppTextStyles.titleMedium),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 7,
            backgroundColor: AppColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    final total = _recyclableScans + _specialScans;

    final percentage = total == 0 ? 0.0 : _recyclableScans / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recycling Rate', style: AppTextStyles.titleMedium),
                    SizedBox(height: 3),
                    Text(
                      'Percentage of recyclable scans',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${(percentage * 100).round()}%',
                style: AppTextStyles.heading3,
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Keep encouraging users to correctly identify and recycle their waste.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
