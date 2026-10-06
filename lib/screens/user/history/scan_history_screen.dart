import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../models/scan_history_model.dart';
import '../../../services/scan_history_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
    ScanHistoryService.instance.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

    ScanHistoryService.instance.removeListener(_onHistoryChanged);

    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _onHistoryChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<ScanHistoryModel> get _filteredScans {
    final query = _searchController.text.trim().toLowerCase();

    return ScanHistoryService.instance.scans.where((scan) {
      final matchesSearch =
          scan.wasteName.toLowerCase().contains(query) ||
          scan.category.toLowerCase().contains(query);

      final matchesFilter = switch (_selectedFilter) {
        'Recyclable' => scan.recyclable,
        'Special' => !scan.recyclable,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scans = _filteredScans;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Scan History'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderSummary(),
            _buildSearchBar(),
            _buildFilterRow(),
            Expanded(
              child:
                  scans.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                        itemCount: scans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildScanCard(
                            context,
                            scans[index],
                            index == 0,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummary() {
    final total = ScanHistoryService.instance.scans.length;

    final recyclable =
        ScanHistoryService.instance.scans
            .where((scan) => scan.recyclable)
            .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.accent),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.recycling_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your recycling journey',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$total scans • $recyclable recyclable',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
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
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search waste or category...',
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
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    const filters = ['All', 'Recyclable', 'Special'];

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

  Widget _buildEmptyState() {
    final bool hasSearch = _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'No matching scans' : 'No scans found',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try searching with another waste name or category.'
                  : 'Your waste scans will appear here after you analyze an item.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasSearch) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text(
                  'Clear Search',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(
    BuildContext context,
    ScanHistoryModel scan,
    bool isLatest,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.scanDetails, arguments: scan);
      },
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isLatest ? AppColors.accent : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryIcon(scan.category),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scan.wasteName,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLatest)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Text(
                            'Latest',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(scan.category, style: AppTextStyles.caption),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        scan.recyclable
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        size: 15,
                        color:
                            scan.recyclable
                                ? AppColors.success
                                : AppColors.warning,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        scan.recyclable ? 'Recyclable' : 'Special Disposal',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              scan.recyclable
                                  ? AppColors.success
                                  : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scan.confidencePercentage,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(scan.date, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(scan.time, style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    final String normalized = category.toLowerCase();

    IconData icon = Icons.recycling_rounded;

    Color background = AppColors.primaryLight;
    Color foreground = AppColors.primary;

    if (normalized.contains('plastic')) {
      icon = Icons.local_drink_rounded;
      background = AppColors.plastic.withValues(alpha: 0.12);
      foreground = AppColors.plastic;
    } else if (normalized.contains('paper')) {
      icon = Icons.description_rounded;
      background = AppColors.paper.withValues(alpha: 0.15);
      foreground = AppColors.paper;
    } else if (normalized.contains('glass')) {
      icon = Icons.wine_bar_rounded;
      background = AppColors.glass.withValues(alpha: 0.12);
      foreground = AppColors.glass;
    } else if (normalized.contains('metal')) {
      icon = Icons.inventory_2_rounded;
      background = AppColors.metal.withValues(alpha: 0.12);
      foreground = AppColors.metal;
    } else if (normalized.contains('e-waste')) {
      icon = Icons.battery_alert_rounded;
      background = AppColors.eWaste.withValues(alpha: 0.12);
      foreground = AppColors.eWaste;
    } else if (normalized.contains('organic')) {
      icon = Icons.eco_rounded;
      background = AppColors.organic.withValues(alpha: 0.14);
      foreground = AppColors.organic;
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: foreground, size: 27),
    );
  }
}
