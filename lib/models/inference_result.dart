class InferenceResult {
  final String category;
  final double confidence;
  final String description;
  final List<String> disposalInstructions;
  final bool recyclable;

  const InferenceResult({
    required this.category,
    required this.confidence,
    required this.description,
    required this.disposalInstructions,
    required this.recyclable,
  });

  String get confidencePercentage {
    return '${(confidence * 100).round()}%';
  }
}
