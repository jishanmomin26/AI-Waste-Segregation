import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../services/image_picker_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();

  bool _isLoading = false;

  void _takePhoto() {
    Navigator.pushNamed(context, AppRoutes.camera);
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await _imagePickerService.pickFromGallery();

      if (!mounted) return;

      if (imagePath != null && imagePath.isNotEmpty) {
        Navigator.pushNamed(
          context,
          AppRoutes.imagePreview,
          arguments: imagePath,
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select the image. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Scan Waste'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntro(),
              const SizedBox(height: 24),
              _buildScanOptions(),
              const SizedBox(height: 24),
              _buildHowItWorks(),
              const SizedBox(height: 24),
              _buildTips(),
              const SizedBox(height: 20),
              _buildSupportedFormats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Identify your waste', style: AppTextStyles.heading1),
        const SizedBox(height: 8),
        Text(
          'Take a clear photo or upload an image and let Reccly identify the waste category for you.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildScanOptions() {
    return Column(
      children: [
        _buildMainScanCard(),
        const SizedBox(height: 14),
        _buildUploadCard(),
      ],
    );
  }

  Widget _buildMainScanCard() {
    return InkWell(
      onTap: _isLoading ? null : _takePhoto,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Take a Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Use your camera to scan a waste item',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Open Camera',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return InkWell(
      onTap: _isLoading ? null : _uploadImage,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  _isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      )
                      : const Icon(
                        Icons.photo_library_outlined,
                        color: AppColors.primary,
                        size: 27,
                      ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload from Gallery',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Choose an existing waste photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    const steps = [
      (
        icon: Icons.camera_alt_outlined,
        title: 'Capture',
        text: 'Take a clear photo of the item.',
      ),
      (
        icon: Icons.auto_awesome_outlined,
        title: 'Analyze',
        text: 'Our AI identifies the waste type.',
      ),
      (
        icon: Icons.recycling_outlined,
        title: 'Recycle',
        text: 'Follow the recommended disposal guide.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: AppTextStyles.titleMedium),
          const SizedBox(height: 18),
          ...List.generate(steps.length, (index) {
            final step = steps[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == steps.length - 1 ? 0 : 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(step.icon, color: AppColors.primary, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${step.title}',
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(step.text, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTips() {
    const tips = [
      'Place the waste item on a clean surface.',
      'Make sure the item is clearly visible.',
      'Avoid dark, blurry or heavily cropped photos.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Text('Tips for better results', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(tip, style: AppTextStyles.bodySmall)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedFormats() {
    return Center(
      child: Text(
        'Supported image formats: JPG, JPEG, PNG',
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}
