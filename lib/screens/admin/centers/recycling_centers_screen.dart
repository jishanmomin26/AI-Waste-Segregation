import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_centers.dart';
import '../../../models/recycling_center_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/admin/center_tile.dart';
import '../../../widgets/common/app_text_field.dart';

class RecyclingCentersScreen extends StatefulWidget {
  const RecyclingCentersScreen({super.key});

  @override
  State<RecyclingCentersScreen> createState() => _RecyclingCentersScreenState();
}

class _RecyclingCentersScreenState extends State<RecyclingCentersScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecyclingCenterModel> get _filteredCenters {
    if (_searchQuery.isEmpty) {
      return DummyCenters.centers;
    }

    return DummyCenters.centers.where((center) {
      return center.name.toLowerCase().contains(_searchQuery) ||
          center.address.toLowerCase().contains(_searchQuery) ||
          center.acceptedMaterials.any(
            (material) => material.toLowerCase().contains(_searchQuery),
          );
    }).toList();
  }

  int get _openCenters {
    return DummyCenters.centers.where((center) => center.openNow).length;
  }

  int get _closedCenters {
    return DummyCenters.centers.where((center) => !center.openNow).length;
  }

  @override
  Widget build(BuildContext context) {
    final centers = _filteredCenters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recycling Centers'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addCenter);
            },
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Center',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSummary(),

            const SizedBox(height: 20),

            AppTextField(
              controller: _searchController,
              hintText: 'Search centers...',
              prefixIcon: Icons.search_rounded,
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                      : null,
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Collection Centers', style: AppTextStyles.heading3),
                Text(
                  '${centers.length} centers',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (centers.isEmpty)
              _buildEmptyState()
            else
              ...centers.map(
                (center) => CenterTile(
                  center: center,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.centerDetails,
                      arguments: center,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Total',
            value: '${DummyCenters.centers.length}',
            icon: Icons.location_city_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            title: 'Open',
            value: '$_openCenters',
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            title: 'Closed',
            value: '$_closedCenters',
            icon: Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text('No centers found', style: AppTextStyles.titleMedium),
          SizedBox(height: 6),
          Text(
            'Try searching with another center name or location.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
