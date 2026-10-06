import '../models/achievement_model.dart';

class DummyAchievements {
  static const List<AchievementModel> achievements = [
    AchievementModel(
      id: '1',
      title: 'First Scan',
      description: 'Complete your first waste scan.',
      icon: 'scan',
      requiredCount: 1,
      currentCount: 1,
      unlocked: true,
    ),

    AchievementModel(
      id: '2',
      title: 'Eco Starter',
      description: 'Complete 5 successful waste scans.',
      icon: 'eco',
      requiredCount: 5,
      currentCount: 5,
      unlocked: true,
    ),

    AchievementModel(
      id: '3',
      title: 'Recycling Rookie',
      description: 'Complete 10 successful waste scans.',
      icon: 'recycling',
      requiredCount: 10,
      currentCount: 8,
      unlocked: false,
    ),

    AchievementModel(
      id: '4',
      title: 'Green Guardian',
      description: 'Complete 25 successful waste scans.',
      icon: 'shield',
      requiredCount: 25,
      currentCount: 12,
      unlocked: false,
    ),

    AchievementModel(
      id: '5',
      title: 'Eco Hero',
      description: 'Complete 50 successful waste scans.',
      icon: 'star',
      requiredCount: 50,
      currentCount: 12,
      unlocked: false,
    ),

    AchievementModel(
      id: '6',
      title: 'Recycling Champion',
      description: 'Complete 100 successful waste scans.',
      icon: 'trophy',
      requiredCount: 100,
      currentCount: 12,
      unlocked: false,
    ),

    AchievementModel(
      id: '7',
      title: 'Plastic Saver',
      description: 'Successfully identify 10 plastic items.',
      icon: 'plastic',
      requiredCount: 10,
      currentCount: 7,
      unlocked: false,
    ),

    AchievementModel(
      id: '8',
      title: 'E-Waste Expert',
      description: 'Successfully identify 5 e-waste items.',
      icon: 'battery',
      requiredCount: 5,
      currentCount: 3,
      unlocked: false,
    ),
  ];
}
