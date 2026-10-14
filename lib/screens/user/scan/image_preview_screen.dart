import 'dart:io' show File;

import 'package:flutter/foundation.dart';
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
  bool _argumentsLoaded = false;
  String _imagePath = '';
  Uint8List? _imageBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentsLoaded) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map<String, dynamic>) {
      _imagePath = arguments['imagePath'] as String? ?? '';
      final dynamic bytes = arguments['imageBytes'];
      if (bytes is Uint8List && bytes.isNotEmpty) {
        _imageBytes = bytes;
      }
      _argumentsLoaded = true;
    } else if (arguments is String && arguments.isNotEmpty) {
      _imagePath = arguments;
      _argumentsLoaded = true;
    } else if (arguments is Uint8List && arguments.isNotEmpty) {
      _imageBytes = arguments;
      _argumentsLoaded = true;
    }

    // On native platforms, if bytes aren't provided but path is, load them
    if (!kIsWeb && _imageBytes == null && _imagePath.isNotEmpty) {
      try {
        final file = File(_imagePath);
        if (file.existsSync()) {
          _imageBytes = file.readAsBytesSync();
        }
      } catch (_) {
        // Fallback to file reading in service if sync read fails
      }
    }
  }

  Future<void> _analyzeWaste() async {
    if (_isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _inferenceService.analyzeImage(
        _imagePath,
        imageBytes: _imageBytes,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.result,
        arguments: {
          'imagePath': _imagePath,
          'imageBytes': _imageBytes,
          'result': result,
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message =
          error is InferenceException
              ? error.message
              : 'Unable to analyze the image. Please try again.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
    final bool hasValidImage =
        (_imageBytes != null && _imageBytes!.isNotEmpty) ||
        (!kIsWeb && _imagePath.isNotEmpty);

    if (!hasValidImage && !_argumentsLoaded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Image Preview')),
        body: const Center(
          child: Text('No image selected.', style: AppTextStyles.bodyMedium),
        ),
      );
    }

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
                  child: _buildPreviewImage(),
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
                        _analyzeWaste();
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

  Widget _buildPreviewImage() {
    // 1. Prefer in-memory bytes (cross-platform, works on Web, Android, iOS, Desktop)
    if (_imageBytes != null && _imageBytes!.isNotEmpty) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }

    // 2. On native platforms, fallback to File if bytes not loaded
    if (!kIsWeb && _imagePath.isNotEmpty) {
      return Image.file(
        File(_imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }

    // 3. On Web, if path is a blob or network URL
    if (kIsWeb &&
        _imagePath.isNotEmpty &&
        (_imagePath.startsWith('blob:') || _imagePath.startsWith('http'))) {
      return Image.network(
        _imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }

    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
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
  }
}
