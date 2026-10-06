import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/recycling_center_model.dart';

class LocationDetailsScreen extends StatelessWidget {
  const LocationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! RecyclingCenterModel) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Center Details')),
        body: const Center(
          child: Text(
            'Center details are not available.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    final center = arguments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Center Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(center),

              const SizedBox(height: 16),

              _buildInformationCard(center),

              const SizedBox(height: 16),

              _buildMaterialsCard(center),

              const SizedBox(height: 16),

              _buildDescriptionCard(center),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Directions feature will be connected later.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.directions_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Get Directions',
                    style: AppTextStyles.button,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Call ${center.phone}')),
                    );
                  },
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text(
                    'Contact Center',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Center information is provided for demonstration. '
                        'Always verify timings before visiting.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RecyclingCenterModel center) {
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            center.name,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                center.openNow
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 17,
                color: center.openNow ? AppColors.primary : Colors.redAccent,
              ),
              const SizedBox(width: 5),
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

  Widget _buildInformationCard(RecyclingCenterModel center) {
    return _buildCard(
      title: 'Center Information',
      icon: Icons.business_outlined,
      child: Column(
        children: [
          _buildInfoRow('Address', center.address, Icons.location_on_outlined),
          const SizedBox(height: 14),
          _buildInfoRow('Distance', center.distance, Icons.route_outlined),
          const SizedBox(height: 14),
          _buildInfoRow('Timing', center.timing, Icons.access_time_outlined),
          const SizedBox(height: 14),
          _buildInfoRow('Phone', center.phone, Icons.phone_outlined),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(RecyclingCenterModel center) {
    return _buildCard(
      title: 'Accepted Materials',
      icon: Icons.recycling_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            center.acceptedMaterials
                .map(
                  (material) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      material,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildDescriptionCard(RecyclingCenterModel center) {
    return _buildCard(
      title: 'About This Center',
      icon: Icons.info_outline_rounded,
      child: Text(center.description, style: AppTextStyles.bodyMedium),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppTextStyles.bodySmall)),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.labelMedium,
          ),
        ),
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
