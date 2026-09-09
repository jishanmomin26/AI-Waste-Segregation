import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_waste.dart';
import '../../../models/waste_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class WasteManagementScreen extends StatefulWidget {
  const WasteManagementScreen({super.key});

  @override
  State<WasteManagementScreen> createState() => _WasteManagementScreenState();
}

class _WasteManagementScreenState extends State<WasteManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<WasteModel> _filteredCategories = DummyWaste.categories;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterCategories);
  }

  void _filterCategories() {
    final String query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredCategories = DummyWaste.categories;
        return;
      }

      _filteredCategories =
          DummyWaste.categories.where((category) {
            return category.name.toLowerCase().contains(query) ||
                category.description.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'plastic':
        return Icons.local_drink_outlined;

      case 'paper':
        return Icons.description_outlined;

      case 'glass':
        return Icons.wine_bar_outlined;

      case 'metal':
        return Icons.inventory_2_outlined;

      case 'e_waste':
        return Icons.devices_outlined;

      case 'organic':
        return Icons.eco_outlined;

      default:
        return Icons.recycling_rounded;
    }
  }

  void _openEditCategory(WasteModel category) {
    Navigator.pushNamed(
      context,
      AppRoutes.editWasteCategory,
      arguments: category,
    );
  }

  void _showDeleteDialog(WasteModel category) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category.name} deleted in demo mode.'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalCategories = DummyWaste.categories.length;

    final int recyclableCategories =
        DummyWaste.categories.where((category) => category.recyclable).length;

    final int specialCategories = totalCategories - recyclableCategories;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Waste Management'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addWasteCategory);
            },
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Text('Waste Categories', style: AppTextStyles.heading2),

          const SizedBox(height: 5),

          Text(
            'Manage the waste categories used by Reccly.',
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
                  value: '$totalCategories',
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  title: 'Recyclable',
                  value: '$recyclableCategories',
                  icon: Icons.recycling_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  title: 'Special',
                  value: '$specialCategories',
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
              hintText: 'Search waste categories',
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

          const SizedBox(height: 22),

          // ==================================================
          // HEADER
          // ==================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: AppTextStyles.heading3),
              Text(
                '${_filteredCategories.length} items',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ==================================================
          // CATEGORY LIST
          // ==================================================
          if (_filteredCategories.isEmpty)
            _EmptyCategories()
          else
            ..._filteredCategories.map(
              (category) => _WasteCategoryCard(
                category: category,
                icon: _getIcon(category.icon),
                onEdit: () {
                  _openEditCategory(category);
                },
                onDelete: () {
                  _showDeleteDialog(category);
                },
              ),
            ),

          const SizedBox(height: 16),

          // ==================================================
          // ADD CATEGORY BUTTON
          // ==================================================
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addWasteCategory);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Waste Category'),
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
// WASTE CATEGORY CARD
// ============================================================

class _WasteCategoryCard extends StatelessWidget {
  final WasteModel category;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WasteCategoryCard({
    required this.category,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 25),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            category.recyclable
                                ? AppColors.primaryLight
                                : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.recyclable ? 'Recyclable' : 'Special',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              category.recyclable
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  category.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${category.totalScans} scans',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 19),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 19),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

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
            Icons.category_outlined,
            size: 50,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text('No categories found', style: AppTextStyles.titleMedium),
          const SizedBox(height: 5),
          Text(
            'Try searching for another category.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
