// ignore_for_file: avoid_print
import 'dart:io';

import 'package:recycle_app/models/inference_result.dart';

void main() {
  print('====================================================');
  print('Running InferenceResult & Asset Verification Tests');
  print('====================================================');

  int passed = 0;
  int failed = 0;

  void assertTest(String name, bool condition, [String? errorMsg]) {
    if (condition) {
      print(' [PASS] $name');
      passed++;
    } else {
      print(' [FAIL] $name: ${errorMsg ?? 'Assertion failed'}');
      failed++;
    }
  }

  // 1. Test InferenceResult Model
  print('\n--- Group 1: InferenceResult Model ---');
  final result = InferenceResult(
    category: 'Plastic',
    confidence: 0.942,
    description: 'Recyclable plastic container.',
    disposalInstructions: const [
      'Empty the container.',
      'Rinse with water.',
      'Place in recycling bin.',
    ],
    recyclable: true,
  );

  assertTest('Category matches', result.category == 'Plastic');
  assertTest('Confidence matches', (result.confidence - 0.942).abs() < 1e-6);
  assertTest('Confidence percentage formatted correctly (94%)', result.confidencePercentage == '94%');
  assertTest('Recyclable flag is true', result.recyclable == true);
  assertTest('Disposal instructions count', result.disposalInstructions.length == 3);

  final edgeResult0 = InferenceResult(
    category: 'Trash',
    confidence: 0.0,
    description: 'Unknown',
    disposalInstructions: const [],
    recyclable: false,
  );
  assertTest('Zero confidence formatted as 0%', edgeResult0.confidencePercentage == '0%');

  final edgeResult1 = InferenceResult(
    category: 'Metal',
    confidence: 1.0,
    description: 'Metal can',
    disposalInstructions: const [],
    recyclable: true,
  );
  assertTest('100% confidence formatted as 100%', edgeResult1.confidencePercentage == '100%');

  // 2. Test Labels file
  print('\n--- Group 2: Labels File Verification ---');
  final labelsFile = File('labels/labels.txt');
  assertTest('labels/labels.txt exists on disk', labelsFile.existsSync());

  final labels = labelsFile
      .readAsStringSync()
      .split(RegExp(r'\r?\n'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  assertTest('Labels count is 6', labels.length == 6);
  final expectedLabels = ['cardboard', 'glass', 'metal', 'paper', 'plastic', 'trash'];
  assertTest('Labels match exact expected classes', labels.toString() == expectedLabels.toString());

  // 3. Test Model File Integrity
  print('\n--- Group 3: Model Asset Verification ---');
  final modelFile = File('model/trash_classifier.tflite');
  assertTest('model/trash_classifier.tflite exists', modelFile.existsSync());
  final modelBytes = modelFile.readAsBytesSync();
  assertTest('Model size is > 4MB', modelBytes.length > 4 * 1024 * 1024);
  final identifier = String.fromCharCodes(modelBytes.sublist(4, 8));
  assertTest('Model format is TFLite (TFL3 identifier)', identifier == 'TFL3');

  // 4. Test Preprocessing Normalization Math
  print('\n--- Group 4: Preprocessing Math ---');
  double normalize(int pixel) => (pixel - 127.5) / 127.5;
  assertTest('Pixel 0 maps to -1.0', (normalize(0) - (-1.0)).abs() < 1e-5);
  assertTest('Pixel 255 maps to 1.0', (normalize(255) - 1.0).abs() < 1e-5);
  assertTest('Pixel 128 maps near 0.0', (normalize(128)).abs() < 0.01);

  // Summary
  print('\n====================================================');
  print('Test Summary: $passed passed, $failed failed');
  print('====================================================');

  if (failed > 0) {
    exit(1);
  }
}
