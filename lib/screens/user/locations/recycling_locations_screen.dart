import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_centers.dart';
import '../../../models/recycling_center_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class RecyclingLocationsScreen extends StatefulWidget {
  const RecyclingLocationsScreen({super.key});

  @override
  State<RecyclingLocationsScreen> createState() =>
      _RecyclingLocationsScreenState();
}

class _RecyclingLocationsScreenState extends State<RecyclingLocationsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecyclingCenterModel> get _filteredCenters {
    final query = _searchController.text.trim().toLowerCase();

    return DummyCenters.centers.where((center) {
      final matchesSearch =
          center.name.toLowerCase().contains(query) ||
          center.address.toLowerCase().contains(query) ||
          center.acceptedMaterials.any(
            (material) => material.toLowerCase().contains(query),
          );

      final matchesFilter = switch (_selectedFilter) {
        'Open Now' => center.openNow,
        'Closed' => !center.openNow,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final centers = _filteredCenters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Recycling Centers'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            _buildIntro(),
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child:
                  centers.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        itemCount: centers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildCenterCard(context, centers[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find a recycling center', style: AppTextStyles.heading2),
            const SizedBox(height: 5),
            Text(
              'Find nearby places where you can responsibly dispose of waste.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search centers or materials...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: _searchController.clear,
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.textSecondary,
                    ),
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Open Now', 'Closed'];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter == _selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterCard(BuildContext context, RecyclingCenterModel center) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.locationDetails,
          arguments: center,
        );
      },
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    color: AppColors.primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(center.name, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              center.address,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _buildStatusBadge(center.openNow),
              ],
            ),
            const SizedBox(height: 15),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 13),
            Row(
              children: [
                _buildMeta(Icons.near_me_outlined, center.distance),
                const SizedBox(width: 16),
                _buildMeta(Icons.schedule_outlined, center.timing),
              ],
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  center.acceptedMaterials
                      .map(
                        (material) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            material,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool openNow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: openNow ? AppColors.primaryLight : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        openNow ? 'OPEN' : 'CLOSED',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: openNow ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text('No centers found', style: AppTextStyles.heading3),
            const SizedBox(height: 7),
            Text(
              'Try another search or filter.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
