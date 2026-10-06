import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_scans.dart';
import '../../../models/scan_history_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/admin/scan_record_tile.dart';

class ScanRecordsScreen extends StatefulWidget {
  const ScanRecordsScreen({super.key});

  @override
  State<ScanRecordsScreen> createState() => _ScanRecordsScreenState();
}

class _ScanRecordsScreenState extends State<ScanRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ScanHistoryModel> _filteredScans = DummyScans.scans;

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterScans);
  }

  void _filterScans() {
    final String query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredScans =
          DummyScans.scans.where((scan) {
            final bool matchesSearch =
                query.isEmpty ||
                scan.wasteName.toLowerCase().contains(query) ||
                scan.category.toLowerCase().contains(query) ||
                scan.description.toLowerCase().contains(query);

            final bool matchesFilter =
                _selectedFilter == 'All' ||
                (_selectedFilter == 'Recyclable' && scan.recyclable) ||
                (_selectedFilter == 'Special' && !scan.recyclable);

            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    _filterScans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(ScanHistoryModel scan) {
    Navigator.pushNamed(context, AppRoutes.scanRecordDetails, arguments: scan);
  }

  @override
  Widget build(BuildContext context) {
    final int totalScans = DummyScans.scans.length;

    final int recyclableScans =
        DummyScans.scans.where((scan) => scan.recyclable).length;

    final int specialScans = totalScans - recyclableScans;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Scan Records'),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Text('Scan Management', style: AppTextStyles.heading2),

          const SizedBox(height: 5),

          Text(
            'Review waste identification activity across Reccly.',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 20),

          // ==================================================
          // SUMMARY
          // ==================================================
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total',
                  value: '$totalScans',
                  icon: Icons.document_scanner_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  title: 'Recyclable',
                  value: '$recyclableScans',
                  icon: Icons.recycling_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  title: 'Special',
                  value: '$specialScans',
                  icon: Icons.warning_amber_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==================================================
          // SEARCH
          // ==================================================
          TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search scans or categories',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.close_rounded),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // FILTERS
          // ==================================================
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == 'All',
                  onTap: () {
                    _changeFilter('All');
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Recyclable',
                  selected: _selectedFilter == 'Recyclable',
                  onTap: () {
                    _changeFilter('Recyclable');
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Special',
                  selected: _selectedFilter == 'Special',
                  onTap: () {
                    _changeFilter('Special');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ==================================================
          // LIST HEADER
          // ==================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Records', style: AppTextStyles.heading3),
              Text(
                '${_filteredScans.length} records',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ==================================================
          // SCAN LIST
          // ==================================================
          if (_filteredScans.isEmpty)
            _EmptyScans()
          else
            ..._filteredScans.map(
              (scan) => ScanRecordTile(
                scan: scan,
                onTap: () {
                  _openDetails(scan);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 9),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ============================================================
// FILTER CHIP
// ============================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyScans extends StatelessWidget {
  const _EmptyScans();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.document_scanner_outlined,
            size: 50,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text('No scan records found', style: AppTextStyles.titleMedium),
          const SizedBox(height: 5),
          Text(
            'Try changing the search or filter.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
