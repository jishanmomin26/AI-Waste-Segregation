class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String joinedDate;
  final int ecoPoints;
  final int totalScans;
  final int successfulScans;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.joinedDate,
    required this.ecoPoints,
    required this.totalScans,
    required this.successfulScans,
  });
}
