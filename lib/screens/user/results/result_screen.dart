import 'dart:io';

import 'package:flutter/material.dart';

import '../../../constants/app_routes.dart';
import '../../../models/inference_result.dart';
import '../../../models/scan_history_model.dart';
import '../../../services/scan_history_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String imagePath;
  late InferenceResult result;

  bool _argumentsLoaded = false;
  bool _scanSaved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentsLoaded) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map<String, dynamic>) {
      final dynamic path = arguments['imagePath'];
      final dynamic inference = arguments['result'];

      if (path is String && inference is InferenceResult) {
        imagePath = path;
        result = inference;
        _argumentsLoaded = true;

        _saveScanToHistory();
      }
    }
  }

  void _saveScanToHistory() {
    if (_scanSaved || !_argumentsLoaded) {
      return;
    }

    final now = DateTime.now();

    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')} '
        '${_monthName(now.month)} '
        '${now.year}';

    final String hour =
        now.hour == 0
            ? '12'
            : now.hour > 12
            ? (now.hour - 12).toString()
            : now.hour.toString();

    final String minute = now.minute.toString().padLeft(2, '0');

    final String period = now.hour >= 12 ? 'PM' : 'AM';

    final String formattedTime = '$hour:$minute $period';

    final ScanHistoryModel scan = ScanHistoryModel(
      id: 'scan_${now.microsecondsSinceEpoch}',
      wasteName: '${result.category} Item',
      category: result.category,
      confidence: result.confidence,
      date: formattedDate,
      time: formattedTime,
      recyclable: result.recyclable,
      description: result.description,
    );

    ScanHistoryService.instance.addScan(scan);

    _scanSaved = true;
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  void _scanAnotherWaste() {
    Navigator.pushNamed(context, AppRoutes.scan);
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.userMain,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_argumentsLoaded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Scan Result')),
        body: const Center(child: Text('Unable to load scan result.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Scan Result'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSuccessHeader(),
              const SizedBox(height: 18),
              _buildResultImage(),
              const SizedBox(height: 18),
              _buildDetectedWasteCard(),
              const SizedBox(height: 14),
              _buildConfidenceCard(),
              const SizedBox(height: 14),
              _buildDescriptionCard(),
              const SizedBox(height: 14),
              _buildDisposalCard(),
              const SizedBox(height: 22),
              AppButton(
                text: 'Scan Another Waste',
                icon: Icons.camera_alt_rounded,
                onPressed: _scanAnotherWaste,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Back to Home',
                icon: Icons.home_rounded,
                outlined: true,
                onPressed: _goHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Here is what Reccly found.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 23,
          ),
        ],
      ),
    );
  }

  Widget _buildResultImage() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetectedWasteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detected Waste', style: AppTextStyles.bodySmall),
                const SizedBox(height: 3),
                Text(result.category, style: AppTextStyles.heading2),
                const SizedBox(height: 6),
                _buildStatusBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool recyclable = result.recyclable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: recyclable ? AppColors.primaryLight : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            recyclable ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 14,
            color: recyclable ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 5),
          Text(
            recyclable ? 'Recyclable' : 'Special Disposal',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: recyclable ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard() {
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text('AI Confidence', style: AppTextStyles.titleMedium),
              ),
              Text(
                result.confidencePercentage,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: result.confidence,
              minHeight: 9,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The AI is ${result.confidencePercentage} confident about this classification.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text('What We Found', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          Text(result.description, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildDisposalCard() {
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Text('Disposal Guide', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 18),
          ...List.generate(result.disposalInstructions.length, (index) {
            final instruction = result.disposalInstructions[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    index == result.disposalInstructions.length - 1 ? 0 : 13,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(instruction, style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
