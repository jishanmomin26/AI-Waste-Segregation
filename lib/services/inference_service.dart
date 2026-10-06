import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../constants/app_assets.dart';
import '../models/inference_result.dart';

/// Exception thrown when image analysis or model inference encounters an error.
class InferenceException implements Exception {
  final String message;
  final Object? cause;

  const InferenceException(this.message, [this.cause]);

  @override
  String toString() => 'InferenceException: $message';
}

/// Metadata and disposal instructions for a waste category.
class WasteCategoryDetails {
  final String category;
  final bool recyclable;
  final String description;
  final List<String> disposalInstructions;

  const WasteCategoryDetails({
    required this.category,
    required this.recyclable,
    required this.description,
    required this.disposalInstructions,
  });
}

/// Service that performs real on-device waste classification
/// using the trained TensorFlow Lite model.
class InferenceService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool _isInitializing = false;

  static int _inputHeight = 224;
  static int _inputWidth = 224;
  static int _inputChannels = 3;

  /// Dimensions and channels expected by the model input tensor.
  static int get inputHeight => _inputHeight;
  static int get inputWidth => _inputWidth;
  static int get inputChannels => _inputChannels;

  /// Category descriptions and disposal instructions mapped by label.
  static const Map<String, WasteCategoryDetails> _categoryDetailsMap = {
    'cardboard': WasteCategoryDetails(
      category: 'Cardboard',
      recyclable: true,
      description:
          'This item appears to be cardboard. It consists of heavy paper-based packaging materials that are widely recyclable.',
      disposalInstructions: [
        'Remove any tape, staples, or plastic wrap attached to the box.',
        'Flatten the cardboard box completely to save volume in recycling bins.',
        'Keep it clean and dry; discard food-soiled cardboard with general waste.',
        'Place it inside the designated paper/cardboard recycling bin.',
      ],
    ),
    'glass': WasteCategoryDetails(
      category: 'Glass',
      recyclable: true,
      description:
          'This item appears to be glass. Glass bottles and jars can be recycled indefinitely without loss of purity or quality.',
      disposalInstructions: [
        'Empty all liquid or food residue completely.',
        'Rinse the container thoroughly with clean water.',
        'Remove metal or plastic caps and lids to recycle them separately.',
        'Place the intact glass container in the designated glass recycling bin.',
      ],
    ),
    'metal': WasteCategoryDetails(
      category: 'Metal',
      recyclable: true,
      description:
          'This item appears to be metal. Cans and containers made of aluminium or steel are highly recyclable and energy-efficient to process.',
      disposalInstructions: [
        'Empty any remaining beverage or food contents.',
        'Rinse the container with clean water.',
        'Crush aluminium cans if permitted locally to maximize bin space.',
        'Place the clean metal item into the metal recycling container.',
      ],
    ),
    'paper': WasteCategoryDetails(
      category: 'Paper',
      recyclable: true,
      description:
          'This item appears to be paper. Office documents, newspapers, magazines, and paper packaging can be processed into new paper products.',
      disposalInstructions: [
        'Keep paper clean, dry, and free from moisture.',
        'Remove plastic sleeves, bindings, or large metal clips.',
        'Do not recycle paper contaminated with food, grease, or chemicals.',
        'Deposit into the clean paper recycling container.',
      ],
    ),
    'plastic': WasteCategoryDetails(
      category: 'Plastic',
      recyclable: true,
      description:
          'This item appears to be a recyclable plastic container or bottle. Rigid plastics can be cleaned and repurposed into new goods.',
      disposalInstructions: [
        'Empty the container completely of all liquids.',
        'Rinse thoroughly to remove residue and prevent contamination.',
        'Keep caps attached or separate according to local guidelines.',
        'Place into the plastic recycling collection bin.',
      ],
    ),
    'trash': WasteCategoryDetails(
      category: 'Trash',
      recyclable: false,
      description:
          'This item is classified as general non-recyclable waste or contaminated material that should go to landfill.',
      disposalInstructions: [
        'Check if any detachable parts or packaging can be recycled.',
        'Bag the waste securely to prevent litter and odor.',
        'Dispose of it in the general non-recyclable waste bin.',
        'Keep separate from recyclable materials and compost.',
      ],
    ),
  };

  /// Returns true if both the interpreter and labels are loaded into memory.
  bool get isModelLoaded => _interpreter != null && _labels != null;

  /// Initializes the TFLite interpreter and loads the labels from assets.
  Future<void> initialize({
    String modelPath = AppAssets.model,
    String labelsPath = AppAssets.labels,
  }) async {
    if (isModelLoaded) {
      return;
    }

    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (isModelLoaded) return;
    }

    _isInitializing = true;

    try {
      // 1. Load labels list from assets
      final labelsRaw = await rootBundle.loadString(labelsPath);
      final loadedLabels = labelsRaw
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (loadedLabels.isEmpty) {
        throw const InferenceException('Labels file is empty or corrupted.');
      }

      // 2. Initialize TFLite interpreter options
      final options = InterpreterOptions()..threads = 2;

      // 3. Load model from assets
      final interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );

      // 4. Inspect input tensor dimensions dynamically
      final inputTensors = interpreter.getInputTensors();
      if (inputTensors.isNotEmpty) {
        final shape = inputTensors.first.shape;
        if (shape.length == 4) {
          _inputHeight = shape[1];
          _inputWidth = shape[2];
          _inputChannels = shape[3];
        }
      }

      _labels = loadedLabels;
      _interpreter = interpreter;
    } catch (e) {
      _interpreter?.close();
      _interpreter = null;
      _labels = null;
      if (e is InferenceException) rethrow;
      throw InferenceException(
        'Failed to initialize TensorFlow Lite model: $e',
        e,
      );
    } finally {
      _isInitializing = false;
    }
  }

  /// Analyzes an image from [imagePath] and returns the classification result.
  Future<InferenceResult> analyzeImage(String imagePath) async {
    // 1. Validate image path
    if (imagePath.trim().isEmpty) {
      throw const InferenceException('Image path cannot be empty.');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw InferenceException('Image file not found at: $imagePath');
    }

    final Uint8List imageBytes;
    try {
      imageBytes = await file.readAsBytes();
    } catch (e) {
      throw InferenceException('Failed to read image file: $e', e);
    }

    if (imageBytes.isEmpty) {
      throw const InferenceException('Selected image file is empty (0 bytes).');
    }

    // 2. Decode the image into memory
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw const InferenceException(
        'Failed to decode image. Please select a valid JPG, PNG, or WebP photo.',
      );
    }

    // 3. Ensure the model and labels are loaded
    if (!isModelLoaded) {
      await initialize();
    }

    final interpreter = _interpreter;
    final labels = _labels;

    if (interpreter == null || labels == null) {
      throw const InferenceException(
        'TensorFlow Lite interpreter is not available.',
      );
    }

    // 4. Preprocess image into required input tensor shape [1, 224, 224, 3]
    final input = _preprocessImage(decodedImage);

    // 5. Prepare output tensor buffer
    final outputTensors = interpreter.getOutputTensors();
    final int numClasses = outputTensors.isNotEmpty
        ? outputTensors.first.shape.last
        : labels.length;

    final output = List.generate(
      1,
      (_) => List<double>.filled(numClasses, 0.0),
    );

    // 6. Execute model inference
    try {
      interpreter.run(input, output);
    } catch (e) {
      throw InferenceException('Model inference execution failed: $e', e);
    }

    // 7. Parse model output probabilities
    final List<double> probabilities = output.first;
    if (probabilities.isEmpty) {
      throw const InferenceException('Model returned empty predictions.');
    }

    int bestIndex = 0;
    double bestConfidence = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > bestConfidence) {
        bestConfidence = probabilities[i];
        bestIndex = i;
      }
    }

    // Clamp confidence to valid [0.0, 1.0] range
    final double confidence = bestConfidence.clamp(0.0, 1.0);

    // 8. Map class index to label name
    final String predictedLabel =
        bestIndex < labels.length ? labels[bestIndex] : 'unknown';

    final details = getCategoryDetails(predictedLabel);

    return InferenceResult(
      category: details.category,
      confidence: confidence,
      description: details.description,
      disposalInstructions: details.disposalInstructions,
      recyclable: details.recyclable,
    );
  }

  /// Preprocesses the image by resizing to model dimensions and normalizing RGB channels.
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image to model input shape (224x224)
    final img.Image resized = img.copyResize(
      image,
      width: _inputWidth,
      height: _inputHeight,
      interpolation: img.Interpolation.linear,
    );

    // Normalize RGB pixel values to [-1.0, 1.0] for MobileNetV2
    // Formula: (pixel - 127.5) / 127.5
    return List.generate(
      1,
      (_) => List.generate(
        _inputHeight,
        (y) => List.generate(
          _inputWidth,
          (x) {
            final pixel = resized.getPixel(x, y);
            final double r = (pixel.r - 127.5) / 127.5;
            final double g = (pixel.g - 127.5) / 127.5;
            final double b = (pixel.b - 127.5) / 127.5;
            return [r, g, b];
          },
        ),
      ),
    );
  }

  /// Maps a label string to its corresponding category metadata.
  static WasteCategoryDetails getCategoryDetails(String label) {
    final key = label.trim().toLowerCase();
    if (_categoryDetailsMap.containsKey(key)) {
      return _categoryDetailsMap[key]!;
    }

    final capitalized = label.isNotEmpty
        ? '${label[0].toUpperCase()}${label.substring(1)}'
        : 'Unknown Waste';

    return WasteCategoryDetails(
      category: capitalized,
      recyclable: false,
      description: 'Identified as $capitalized item.',
      disposalInstructions: const [
        'Inspect the material to verify if parts can be recycled.',
        'Dispose of according to local municipal guidelines.',
        'Do not mix with hazardous or electronic waste.',
      ],
    );
  }

  /// Disposes of the active TFLite interpreter and cleans up resources.
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
