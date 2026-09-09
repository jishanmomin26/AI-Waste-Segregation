import 'package:flutter/material.dart';

import '../../../data/dummy_profile.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController locationController;

  @override
  void initState() {
    super.initState();

    final user = DummyProfile.currentUser;

    nameController = TextEditingController(text: user.name);
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phone);
    locationController = TextEditingController(text: user.location);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Profile photo selection will be available later.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Change Photo'),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Personal Information',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 14),

          const Text('Full Name', style: AppTextStyles.label),
          const SizedBox(height: 7),

          AppTextField(
            controller: nameController,
            hintText: 'Enter your name',
            prefixIcon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 16),

          const Text('Email Address', style: AppTextStyles.label),
          const SizedBox(height: 7),

          AppTextField(
            controller: emailController,
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          const Text('Phone Number', style: AppTextStyles.label),
          const SizedBox(height: 7),

          AppTextField(
            controller: phoneController,
            hintText: 'Enter your phone number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          const Text('Location', style: AppTextStyles.label),
          const SizedBox(height: 7),

          AppTextField(
            controller: locationController,
            hintText: 'Enter your location',
            prefixIcon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 28),

          AppButton(
            text: 'Save Changes',
            icon: Icons.check_rounded,
            onPressed: _saveProfile,
          ),

          const SizedBox(height: 12),

          AppButton(
            text: 'Cancel',
            outlined: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
