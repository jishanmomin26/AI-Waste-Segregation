import 'package:flutter/material.dart';

import '../../../models/learning_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class LearningDetailsScreen extends StatelessWidget {
  const LearningDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! LearningModel) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Learning Guide')),
        body: const Center(
          child: Text(
            'Learning content is not available.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    final lesson = arguments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learning Guide')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(lesson),

              const SizedBox(height: 18),

              _buildContentCard(lesson),

              const SizedBox(height: 18),

              _buildQuickTipCard(lesson),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LearningModel lesson) {
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
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              _getCategoryIcon(lesson.category),
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            lesson.title,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            lesson.description,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetaItem(Icons.category_outlined, lesson.category),
              const SizedBox(width: 16),
              _buildMetaItem(Icons.access_time_outlined, lesson.readTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(LearningModel lesson) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Recycling Guide', style: AppTextStyles.titleMedium),
            ],
          ),

          const SizedBox(height: 18),

          Text(lesson.content, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildQuickTipCard(LearningModel lesson) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Small recycling habits make a big difference. '
              'Learn about ${lesson.category.toLowerCase()} '
              'and dispose of it responsibly.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink_outlined;

      case 'paper':
        return Icons.description_outlined;

      case 'glass':
        return Icons.wine_bar_outlined;

      case 'metal':
        return Icons.inventory_2_outlined;

      case 'e-waste':
        return Icons.devices_other_outlined;

      case 'organic':
        return Icons.eco_outlined;

      default:
        return Icons.menu_book_outlined;
    }
  }
}
