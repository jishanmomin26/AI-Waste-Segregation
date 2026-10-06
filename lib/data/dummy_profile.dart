import '../models/user_profile_model.dart';

class DummyProfile {
  static const UserProfileModel currentUser = UserProfileModel(
    id: 'user_001',
    name: 'Hammad',
    email: 'hammad@example.com',
    phone: '+91 98765 43210',
    location: 'Navi Mumbai, Maharashtra',
    joinedDate: 'September 2026',
    ecoPoints: 240,
    totalScans: 12,
    successfulScans: 12,
  );
}
