class ScanHistoryModel {
  final String id;
  final String wasteName;
  final String category;
  final double confidence;
  final String date;
  final String time;
  final bool recyclable;
  final String description;

  const ScanHistoryModel({
    required this.id,
    required this.wasteName,
    required this.category,
    required this.confidence,
    required this.date,
    required this.time,
    required this.recyclable,
    required this.description,
  });

  String get confidencePercentage {
    return '${(confidence * 100).round()}%';
  }
}
