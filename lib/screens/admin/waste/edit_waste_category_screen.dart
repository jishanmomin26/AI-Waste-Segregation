import 'package:flutter/material.dart';

import '../../../models/waste_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class EditWasteCategoryScreen extends StatefulWidget {
  const EditWasteCategoryScreen({super.key});

  @override
  State<EditWasteCategoryScreen> createState() =>
      _EditWasteCategoryScreenState();
}

class _EditWasteCategoryScreenState extends State<EditWasteCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  bool _recyclable = true;

  bool _initialized = false;

  void _initializeCategory(WasteModel category) {
    if (_initialized) {
      return;
    }

    _initialized = true;

    _nameController.text = category.name;
    _descriptionController.text = category.description;
    _recyclable = category.recyclable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Waste category updated successfully in demo mode.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Object? argument = ModalRoute.of(context)?.settings.arguments;

    final WasteModel? category = argument is WasteModel ? argument : null;

    if (category == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Edit Category')),
        body: const Center(
          child: Text('Category information is not available.'),
        ),
      );
    }

    _initializeCategory(category);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Edit Category'),
        backgroundColor: AppColors.background,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          Text('Edit ${category.name}', style: AppTextStyles.heading2),

          const SizedBox(height: 6),

          Text(
            'Update the category information below.',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 24),

          Text('Category Name', style: AppTextStyles.label),

          const SizedBox(height: 8),

          AppTextField(
            controller: _nameController,
            hintText: 'Category name',
            prefixIcon: Icons.category_outlined,
          ),

          const SizedBox(height: 18),

          Text('Description', style: AppTextStyles.label),

          const SizedBox(height: 8),

          TextField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 6,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Category description',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(16),
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

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recyclable',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Update the recycling status.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Switch(
                  value: _recyclable,
                  onChanged: (value) {
                    setState(() {
                      _recyclable = value;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          AppButton(
            text: 'Save Changes',
            icon: Icons.check_rounded,
            onPressed: _saveChanges,
          ),

          const SizedBox(height: 12),

          AppButton(
            text: 'Cancel',
            outlined: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 20),

          Text(
            'Frontend demo: changes are not persisted to a backend yet.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
