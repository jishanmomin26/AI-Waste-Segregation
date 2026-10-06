class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredCount;
  final int currentCount;
  final bool unlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.currentCount,
    required this.unlocked,
  });

  double get progress {
    if (requiredCount <= 0) {
      return 1.0;
    }

    final double value = currentCount / requiredCount;

    return value.clamp(0.0, 1.0);
  }

  String get progressPercentage {
    return '${(progress * 100).round()}%';
  }
}
