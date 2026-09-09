import '../models/inference_result.dart';

class InferenceService {
  /// Mock AI inference.
  ///
  /// Later, Member 2's actual model/API output
  /// can be connected here.
  Future<InferenceResult> analyzeImage(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));

    return const InferenceResult(
      category: 'Plastic',
      confidence: 0.94,
      description: 'This item appears to be a recyclable plastic container.',
      disposalInstructions: [
        'Empty the container completely.',
        'Rinse it to remove food or liquid residue.',
        'Place it in the plastic recycling bin.',
        'Do not mix it with hazardous waste.',
      ],
      recyclable: true,
    );
  }
}
