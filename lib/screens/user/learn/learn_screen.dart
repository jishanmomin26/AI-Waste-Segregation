import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../data/dummy_learning.dart';
import '../../../models/learning_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'E-Waste',
    'Organic',
  ];

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

  List<LearningModel> get _filteredLessons {
    final query = _searchController.text.trim().toLowerCase();

    return DummyLearning.lessons.where((lesson) {
      final matchesSearch =
          lesson.title.toLowerCase().contains(query) ||
          lesson.category.toLowerCase().contains(query) ||
          lesson.description.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'All' || lesson.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _filteredLessons;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learn'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            _buildIntro(),
            _buildSearchBar(),
            _buildCategories(),
            Expanded(
              child:
                  lessons.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        itemCount: lessons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildLessonCard(context, lessons[index]);
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
            Text('Learn to recycle better', style: AppTextStyles.heading2),
            const SizedBox(height: 5),
            Text(
              'Simple guides to help you make better waste decisions.',
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
          hintText: 'Search recycling guides...',
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

  Widget _buildCategories() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
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

  Widget _buildLessonCard(BuildContext context, LearningModel lesson) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.learningDetails,
          arguments: lesson,
        );
      },
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _buildLessonIcon(lesson.category),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lesson.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lesson.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(lesson.readTime, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonIcon(String category) {
    final normalized = category.toLowerCase();

    IconData icon = Icons.eco_rounded;

    if (normalized.contains('plastic')) {
      icon = Icons.local_drink_rounded;
    } else if (normalized.contains('paper')) {
      icon = Icons.description_rounded;
    } else if (normalized.contains('glass')) {
      icon = Icons.wine_bar_rounded;
    } else if (normalized.contains('metal')) {
      icon = Icons.inventory_2_rounded;
    } else if (normalized.contains('e-waste')) {
      icon = Icons.devices_other_rounded;
    } else if (normalized.contains('organic')) {
      icon = Icons.eco_rounded;
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: AppColors.primary, size: 28),
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
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: AppColors.primary,
                size: 39,
              ),
            ),
            const SizedBox(height: 18),
            Text('No lessons found', style: AppTextStyles.heading3),
            const SizedBox(height: 7),
            Text(
              'Try another search or category.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
