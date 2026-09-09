class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String joinedDate;
  final int totalScans;
  final int ecoPoints;
  final bool active;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.joinedDate,
    required this.totalScans,
    required this.ecoPoints,
    required this.active,
  });
}
