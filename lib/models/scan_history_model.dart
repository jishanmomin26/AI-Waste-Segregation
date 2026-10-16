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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wasteName': wasteName,
      'category': category,
      'confidence': confidence,
      'date': date,
      'time': time,
      'recyclable': recyclable,
      'description': description,
    };
  }

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] as String? ?? '',
      wasteName: json['wasteName'] as String? ?? 'Scanned Item',
      category: json['category'] as String? ?? 'General',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.9,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      recyclable: json['recyclable'] as bool? ?? true,
      description: json['description'] as String? ?? '',
    );
  }
}
