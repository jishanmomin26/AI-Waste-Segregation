import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class AddCenterScreen extends StatefulWidget {
  const AddCenterScreen({super.key});

  @override
  State<AddCenterScreen> createState() => _AddCenterScreenState();
}

class _AddCenterScreenState extends State<AddCenterScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _distanceController = TextEditingController();

  final TextEditingController _timingController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _materialsController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  bool _openNow = true;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _distanceController.dispose();
    _timingController.dispose();
    _phoneController.dispose();
    _materialsController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _saveCenter() {
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _timingController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter center name, address and timing.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recycling center added successfully.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Recycling Center')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Center Information', style: AppTextStyles.heading3),

            const SizedBox(height: 16),

            AppTextField(
              controller: _nameController,
              hintText: 'Center name',
              prefixIcon: Icons.business_outlined,
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: _addressController,
              hintText: 'Address',
              prefixIcon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: _distanceController,
              hintText: 'Distance e.g. 2.5 km',
              prefixIcon: Icons.route_outlined,
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: _timingController,
              hintText: 'Timing e.g. 9 AM - 7 PM',
              prefixIcon: Icons.access_time_outlined,
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: _phoneController,
              hintText: 'Phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: _materialsController,
              hintText: 'Accepted materials',
              prefixIcon: Icons.recycling_outlined,
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: _descriptionController,
              hintText: 'Description',
              prefixIcon: Icons.description_outlined,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Open now', style: AppTextStyles.titleSmall),
                subtitle: Text(
                  _openNow
                      ? 'Center is currently available'
                      : 'Center is currently closed',
                  style: AppTextStyles.bodySmall,
                ),
                value: _openNow,

                // Flutter 3.31+ replacement for deprecated activeColor
                activeThumbColor: AppColors.primary,

                onChanged: (value) {
                  setState(() {
                    _openNow = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Save Center',
              icon: Icons.save_outlined,
              onPressed: _saveCenter,
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

            Container(
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
                      'This is a frontend demo. Center data is not saved to a backend yet.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
