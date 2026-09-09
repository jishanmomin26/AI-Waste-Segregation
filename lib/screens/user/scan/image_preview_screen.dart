import 'dart:io';

import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../services/inference_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final InferenceService _inferenceService = InferenceService();

  bool _isAnalyzing = false;

  Future<void> _analyzeWaste(String imagePath) async {
    if (_isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _inferenceService.analyzeImage(imagePath);

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.result,
        arguments: {'imagePath': imagePath, 'result': result},
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to analyze the image. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! String || arguments.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Image Preview')),
        body: const Center(
          child: Text('No image selected.', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    final String imagePath = arguments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Image Preview')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 56,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Unable to preview this image.',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  const Text(
                    'Ready to identify this waste?',
                    style: AppTextStyles.titleMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Our AI model will analyze the image and '
                    'suggest the waste category.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 18),

                  if (_isAnalyzing)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Analyzing waste image...',
                              style: AppTextStyles.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AppButton(
                      text: 'Analyze Waste',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: () {
                        _analyzeWaste(imagePath);
                      },
                    ),

                  const SizedBox(height: 12),

                  AppButton(
                    text: 'Choose Another Image',
                    icon: Icons.refresh_rounded,
                    outlined: true,
                    onPressed:
                        _isAnalyzing
                            ? () {}
                            : () {
                              Navigator.pop(context);
                            },
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
