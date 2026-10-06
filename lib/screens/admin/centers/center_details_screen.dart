import 'package:flutter/material.dart';

import '../../../models/recycling_center_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class CenterDetailsScreen extends StatelessWidget {
  const CenterDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! RecyclingCenterModel) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Center Details')),
        body: const Center(child: Text('Center information not found.')),
      );
    }

    final center = args;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Center Details'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Edit center feature is available in demo mode.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(center),

            const SizedBox(height: 20),

            _buildInformationSection(center),

            const SizedBox(height: 16),

            _buildMaterialsSection(center),

            const SizedBox(height: 16),

            _buildDescriptionSection(center),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delete center is a frontend demo action.'),
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete Center'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RecyclingCenterModel center) {
    return Container(
      padding: const EdgeInsets.all(20),
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

          const SizedBox(height: 14),

          Text(
            center.name,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                center.openNow
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                size: 17,
                color: center.openNow ? AppColors.primary : Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Text(
                center.openNow ? 'Open now' : 'Currently closed',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: center.openNow ? AppColors.primary : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(RecyclingCenterModel center) {
    return _sectionCard(
      title: 'Center Information',
      children: [
        _infoRow(Icons.location_on_outlined, 'Address', center.address),
        _infoRow(Icons.route_outlined, 'Distance', center.distance),
        _infoRow(Icons.access_time_outlined, 'Timing', center.timing),
        _infoRow(Icons.phone_outlined, 'Phone', center.phone),
      ],
    );
  }

  Widget _buildMaterialsSection(RecyclingCenterModel center) {
    return _sectionCard(
      title: 'Accepted Materials',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              center.acceptedMaterials.map((material) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    material,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(RecyclingCenterModel center) {
    return _sectionCard(
      title: 'Description',
      children: [Text(center.description, style: AppTextStyles.bodyMedium)],
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                const SizedBox(height: 3),
                Text(value, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
